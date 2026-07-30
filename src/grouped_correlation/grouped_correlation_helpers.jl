#=
List of the grouped correlation helpers functions
- get_grouped_correlation_coords
	Orders variables through a classification hierarchy, computes their correlation
	matrix, and returns the spans occupied by every class at every level.

=#


"""
get_grouped_correlation_coords(data::AbstractMatrix{<:Real},
								  variable_names::AbstractVector,
								  hierarchy::AbstractVector{<:AbstractVector};
								  levelnames::AbstractVector = String[]) =>

Orders variables through a classification hierarchy and computes their correlation
matrix.

## Arguments
- `data` is the data matrix, observations (rows) by variables (columns).
- `variable_names` contains one name per variable column.
- `hierarchy` is a vector of classification vectors, one vector per hierarchy level
  and one value per variable. The first vector is the broadest class, the second is
  its subclass, and any later vectors continue the hierarchy.
- `levelnames` contains one display name per hierarchy level, default is `String[]`
  in which case the levels are named `"Level 1"`, `"Level 2"`, and so on.

## Output
- `z` is the variable-by-variable correlation matrix after ordering.
- `names` contains the variable names in plotting order.
- `lnames` contains the names of the hierarchy levels.
- `spans` contains one vector per hierarchy level. Each span records the class label,
  its first and last variable positions, its midpoint, and its share of all
  variables.

The ordering is alphabetical at every level. Variables are first ordered by the
broadest class, then by each nested class in turn, and finally by variable name.
Class spans are defined by the complete prefix of the hierarchy, so two subclasses
with the same name under different parent classes remain separate.

"""
function get_grouped_correlation_coords(data::AbstractMatrix{<:Real},
	variable_names::AbstractVector,
	hierarchy::AbstractVector{<:AbstractVector};
	levelnames::AbstractVector = String[])

	nobs, nvar = size(data)

	if nobs < 2
		error("Grouped Correlation Plots should be given at least two observations.  Got: $(nobs)")
	end

	if nvar < 2
		error("Grouped Correlation Plots should be given at least two variables.  Got: $(nvar)")
	end

	if length(variable_names) != nvar
		error("Grouped Correlation names should be given one per variable.  Got: $(length(variable_names)) for $(nvar)")
	end

	if isempty(hierarchy)
		error("Grouped Correlation Plots should be given at least one classification level.  Got: none")
	end

	if any(length(level) != nvar for level in hierarchy)
		got = [length(level) for level in hierarchy]
		error("Grouped Correlation classifications should be given one per variable.  Got: $(got) for $(nvar)")
	end

	if !isempty(levelnames) && length(levelnames) != length(hierarchy)
		error("Grouped Correlation levelnames should be given one per hierarchy level.  Got: $(length(levelnames)) for $(length(hierarchy))")
	end

	if any(ismissing, variable_names) ||
	   any(level -> any(ismissing, level), hierarchy)
		error("Grouped Correlation names and classifications should not contain missing values.")
	end

	X = Float64.(data)

	if any(!isfinite, X)
		error("Grouped Correlation data should contain only finite values.")
	end

	# a constant variable has no defined correlation, so fail before the heatmap is
	# filled with NaNs and name the columns that need attention
	v_constant = vec(std(X, dims = 1)) .== 0
	if any(v_constant)
		constant_names = string.(variable_names[v_constant])
		error("Grouped Correlation variables should have nonzero variation.  Got constant: $(constant_names)")
	end

	names = string.(variable_names)
	hlevels = [string.(level) for level in hierarchy]

	########################
	# Hierarchical ordering #
	########################

	# a tuple gives the sort its hierarchy: broadest class first, then every nested
	# class, then the variable itself. Lowercase makes the alphabetical order
	# independent of capitalization while MergeSort preserves input order for ties
	keys = [tuple((lowercase(level[i]) for level in hlevels)...,
				  lowercase(names[i])) for i in 1:nvar]
	ord = sortperm(keys; alg = MergeSort)

	X = X[:, ord]
	names = names[ord]
	hlevels = [level[ord] for level in hlevels]

	######################
	# Correlation matrix #
	######################

	z = cor(X)

	###################
	# Hierarchy spans #
	###################

	spans = Vector{Vector{NamedTuple}}()

	for depth in 1:length(hlevels)
		level_spans = NamedTuple[]
		firstidx = 1

		# classes at a nested level are distinguished by their complete prefix. This
		# keeps, for example, a "lipid" subclass under class A separate from a "lipid"
		# subclass under class B
		for i in 2:(nvar + 1)
			same_group = i <= nvar &&
				all(hlevels[d][i] == hlevels[d][firstidx] for d in 1:depth)

			if !same_group
				lastidx = i - 1
				push!(level_spans, (
					label = hlevels[depth][firstidx],
					path = Tuple(hlevels[d][firstidx] for d in 1:depth),
					first = firstidx,
					last = lastidx,
					center = (firstidx + lastidx) / 2,
					fraction = (lastidx - firstidx + 1) / nvar,
				))
				firstidx = i
			end
		end

		push!(spans, level_spans)
	end

	lnames = isempty(levelnames) ?
		["Level $(i)" for i in 1:length(hlevels)] :
		string.(levelnames)

	return z, names, lnames, spans
end


"""
get_grouped_correlation_coords(data::AbstractDataFrame, metadata::AbstractDataFrame;
								  variable_col::Symbol,
								  group_cols::Vector{Symbol}) =>

Selects variable columns from a DataFrame through a metadata table, orders them
through their classification hierarchy, and computes their correlation matrix.

## Arguments
- `data` is the data table, observations (rows) by variables (columns). It may
  contain additional non-variable columns; only variables present in `metadata`
  are selected.
- `metadata` contains one row per variable to draw.
- `variable_col` is the metadata column holding variable identifiers. Each
  identifier must match a column name in `data`.
- `group_cols` lists the metadata columns that define the hierarchy, broadest first.
  One class column gives a class-only plot; two give class then subclass; later
  columns continue the same pattern.

"""
function get_grouped_correlation_coords(data::AbstractDataFrame,
	metadata::AbstractDataFrame;
	variable_col::Symbol,
	group_cols::Vector{Symbol})

	if !(variable_col in propertynames(metadata))
		error("Grouped Correlation metadata should contain variable column $(variable_col).")
	end

	if isempty(group_cols)
		error("Grouped Correlation group_cols should contain at least one classification column.")
	end

	missing_cols = [col for col in group_cols if !(col in propertynames(metadata))]
	if !isempty(missing_cols)
		error("Grouped Correlation metadata is missing classification columns: $(missing_cols)")
	end

	if nrow(metadata) < 2
		error("Grouped Correlation metadata should contain at least two variables.  Got: $(nrow(metadata))")
	end

	if any(ismissing, metadata[!, variable_col]) ||
	   any(col -> any(ismissing, metadata[!, col]), group_cols)
		error("Grouped Correlation metadata identifiers and classifications should not contain missing values.")
	end

	variables = string.(metadata[!, variable_col])

	if length(unique(variables)) != length(variables)
		error("Grouped Correlation metadata should contain each variable once.  Got duplicate identifiers.")
	end

	# match identifiers as strings, since DataFrame column names are Symbols while
	# identifiers in a metadata table are commonly stored as strings
	data_names = string.(names(data))
	data_idx = Dict(name => i for (i, name) in enumerate(data_names))
	not_found = [name for name in variables if !haskey(data_idx, name)]

	if !isempty(not_found)
		error("Grouped Correlation metadata identifiers were not found in data: $(not_found)")
	end

	colidx = [data_idx[name] for name in variables]
	raw = Matrix(select(data, colidx))

	if any(value -> !(value isa Real), raw)
		error("Grouped Correlation variable columns should contain only real, non-missing values.")
	end

	X = Float64.(raw)
	hierarchy = [collect(metadata[!, col]) for col in group_cols]

	return get_grouped_correlation_coords(X, variables, hierarchy;
		levelnames = string.(group_cols))
end
