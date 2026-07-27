#=
List of the loadings heatmap helpers functions
- get_loadings_heatmap_coords
	Returns the loadings of a fitted model, ready for plotting as a heatmap, together
	with the names of the variables and of the components they belong to.

=#


"""
get_loadings_heatmap_coords(loadings::Matrix{Float64}; comps::Vector{Int} = Int[],
							varnames::Vector{String} = String[],
							compnames::Vector{String} = String[],
							nonzero::Bool = false, ntop::Int = 0) =>

Returns the loadings of a fitted model, ready for plotting as a heatmap, together with
the names of the variables and of the components they belong to.

## Arguments
- `loadings` is the matrix of loadings, variables (rows) by components (columns). Any
  set of variable weights can be given: the loadings of a PCA or a sparse PCA, the
  right factors of a penalized matrix decomposition, the X loadings of a PLS
  regression, the loadings of a discriminant model, the canonical directions of a CCA,
  or the joint loadings of a block of a JIVE model.
- `comps` is a vector naming the components to be drawn, default is `Int[]` for all of
  them. Unlike the loadings plot, which draws one component, the heatmap draws them
  together, which is what shows whether two components select the same variables.
- `varnames` is a vector of names, one per variable, default is `String[]` for no
  names, in which case the variables are named by their index. They are subset along
  with the loadings, which is why they are given here rather than passed to the plot
  as `yticks`: the caller cannot know which variables `nonzero` and `ntop` will keep.
- `compnames` is a vector of names, one per component, default is `String[]` for no
  names, in which case the components are named by their index. They are subset along
  with the loadings too, following `comps`.
- `nonzero` keeps only the variables whose loading is not zero on AT LEAST ONE of the
  components drawn, default is `false`. This is what the models with an L1 penalty
  need, since most of their rows are zero throughout and leave the heatmap a flat
  field of the midtone.
- `ntop` keeps only the `ntop` variables of largest absolute loading, taken over the
  components drawn and returned in variable order, default is `0` for all of them.
  This is what the dense models need, since a heatmap of thousands of rows resolves to
  nothing. When `nonzero` is also given, the zeros are dropped first and the largest of
  what remains are kept.

## Output
- `z` matrix contains the loadings kept, variables (rows) by components (columns).
- `xnames` vector contains the names of the components drawn.
- `ynames` vector contains the names of the variables kept.

"""
function get_loadings_heatmap_coords(loadings::Matrix{Float64}; comps::Vector{Int} = Int[],
	varnames::Vector{String} = String[],
	compnames::Vector{String} = String[],
	nonzero::Bool = false, ntop::Int = 0)

	ncomp = size(loadings, 2)

	# check that a name was given for every variable, when any were given
	if !isempty(varnames) && length(varnames) != size(loadings, 1)
		error("Loadings Heatmap varnames should be given one per variable.  Got: $(length(varnames)) for $(size(loadings, 1))")
	end

	# check that a name was given for every component, when any were given
	if !isempty(compnames) && length(compnames) != ncomp
		error("Loadings Heatmap compnames should be given one per component.  Got: $(length(compnames)) for $(ncomp)")
	end

	#######################
	# Components to keep  #
	#######################

	# every component is drawn when none were named
	jdx = isempty(comps) ? collect(1:ncomp) : comps

	for j in jdx
		check_comps(j, ncomp)
	end

	######################
	# Variables to keep  #
	######################

	idx = collect(1:size(loadings, 1))

	# drop the variables the penalty zeroed out on every component drawn, since a row
	# of zeros carries nothing and only pushes the rest of the map together
	if nonzero
		idx = idx[[any(loadings[i, jdx] .!= 0) for i in idx]]
	end

	if isempty(idx)
		error("Loadings Heatmap Plots should be given at least one variable to draw.  Got: none on components $(jdx)")
	end

	# rank by the largest loading a variable reaches on ANY of the components drawn,
	# then put them back in variable order so the axis still reads as the data does
	if ntop > 0 && ntop < length(idx)
		peak = [maximum(abs, loadings[i, jdx]) for i in idx]
		ord = sortperm(peak, rev = true)
		idx = sort(idx[ord[1:ntop]])
	end

	z = loadings[idx, jdx]

	# the variables and the components are named by their index when no names were given
	if isempty(varnames)
		ynames = ["$(i)" for i in idx]
	else
		ynames = varnames[idx]
	end

	if isempty(compnames)
		xnames = ["$(j)" for j in jdx]
	else
		xnames = compnames[jdx]
	end

	return z, xnames, ynames
end
