#=
List of the loadings helpers functions
- get_loadings_coords
	Returns the loadings of one component of a matrix of loadings, ready for plotting,
	together with the names of the variables they belong to.

=#


"""
get_loadings_coords(loadings::Matrix{Float64}; comp::Int = 1,
					varnames::Vector{String} = String[],
					nonzero::Bool = false, ntop::Int = 0) =>

Returns the loadings of one component of a matrix of loadings, ready for plotting,
together with the names of the variables they belong to.

## Arguments
- `loadings` is the matrix of loadings, variables (rows) by components (columns). Any
  set of variable weights can be given: the loadings of a PCA or a sparse PCA, the
  right factors of a penalized matrix decomposition, the X loadings of a PLS
  regression, the loadings of a discriminant model, the canonical directions of a CCA,
  or the joint loadings of a block of a JIVE model.
- `comp` is the component whose loadings are drawn, default is `1`.
- `varnames` is a vector of names, one per variable, default is `String[]` for no
  names, in which case the variables are named by their index. They are subset along
  with the loadings, which is why they are given here rather than passed to the plot
  as `xticks`: the caller cannot know which variables `nonzero` and `ntop` will keep.
- `nonzero` keeps only the variables whose loading is not zero, default is `false`.
  This is what the models with an L1 penalty need, since most of their loadings sit
  exactly at zero and drawing them all leaves the selected ones lost in a flat line.
- `ntop` keeps only the `ntop` variables of largest absolute loading, in variable
  order, default is `0` for all of them. This is what the dense models need, since a
  loading over thousands of variables is not readable. When `nonzero` is also given,
  the zeros are dropped first and the largest of what remains are kept.

## Output
- `x` vector contains the positions of the variables kept, one to the number kept.
- `y` vector contains the loadings of the variables kept on the component.
- `names` vector contains the names of the variables kept, or their indices as strings
  when no `varnames` were given.

"""
function get_loadings_coords(loadings::Matrix{Float64}; comp::Int = 1,
	varnames::Vector{String} = String[],
	nonzero::Bool = false, ntop::Int = 0)

	check_comps(comp, size(loadings, 2))

	# check that a name was given for every variable, when any were given
	if !isempty(varnames) && length(varnames) != size(loadings, 1)
		error("Loadings varnames should be given one per variable.  Got: $(length(varnames)) for $(size(loadings, 1))")
	end

	v = loadings[:, comp]

	######################
	# Variables to keep  #
	######################

	idx = collect(1:length(v))

	# drop the variables the penalty zeroed out, so the selected ones stand alone
	if nonzero
		idx = idx[v[idx] .!= 0]
	end

	if isempty(idx)
		error("Loadings Plots should be given a component with at least one variable to draw.  Got: none on component $(comp)")
	end

	# keep the largest by magnitude, then put them back in variable order so the axis
	# still reads left to right as the data does
	if ntop > 0 && ntop < length(idx)
		ord = sortperm(abs.(v[idx]), rev = true)
		idx = sort(idx[ord[1:ntop]])
	end

	x = collect(1:length(idx))
	y = v[idx]

	# the variables are named by their index when no names were given
	if isempty(varnames)
		names = ["$(i)" for i in idx]
	else
		names = varnames[idx]
	end

	return x, y, names
end
