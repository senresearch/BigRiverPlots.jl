#=
List of the sparsity helpers functions
- get_sparsity_coords
	Returns the count of selected variables per component of a loading matrix, ready
	for plotting, together with the names of the components they belong to.

=#


"""
get_sparsity_coords(loadings::Matrix{Float64}; comps::Vector{Int} = Int[], ncomp::Int = 0,
					compnames::Vector{String} = String[], asfraction::Bool = false) =>

Returns the count of selected variables per component of a loading matrix, ready for
plotting, together with the names of the components they belong to.

## Arguments
- `loadings` is a matrix of loadings, variables (rows) by components (columns), from a
  model with an L1 penalty: the loadings of a sparse PCA, the right factors of a
  penalized matrix decomposition, the loadings of a sparse discriminant model, or the
  canonical vectors of a sparse CCA. A variable is counted as selected on a component
  when its loading there is not zero.
- `comps` is a vector naming the components to be drawn, default is `Int[]` for all of
  them. It selects an explicit, possibly non contiguous, set, such as `[1, 3, 4]`.
- `ncomp` is the number of leading components to keep, default is `0` for all of them.
  It is a shorthand for the leading `ncomp` components, and is ignored when `comps` is
  given.
- `compnames` is a vector of names, one per component of `loadings`, default is
  `String[]` for no names, in which case the components are named by their index. They
  are subset along with the counts, following `comps`, which is why they are given here
  rather than passed to the plot as ticks.
- `asfraction` returns the fraction of the variables selected rather than the count,
  default is `false`. On a model with many variables the fraction reads more easily than
  a raw count, since it does not depend on knowing how many variables there are.

## Output
- `x` vector contains the positions of the components kept, one to the number kept.
- `y` vector contains the number of variables selected on each component, or the
  fraction when asked.
- `names` vector contains the names of the components kept, or their indices as strings
  when no `compnames` were given.

"""
function get_sparsity_coords(loadings::Matrix{Float64}; comps::Vector{Int} = Int[],
	ncomp::Int = 0, compnames::Vector{String} = String[],
	asfraction::Bool = false)

	p, ntotal = size(loadings)

	# check that a name was given for every component, when any were given
	if !isempty(compnames) && length(compnames) != ntotal
		error("Sparsity compnames should be given one per component.  Got: $(length(compnames)) for $(ntotal)")
	end

	#######################
	# Components to keep  #
	#######################

	# comps names an explicit set, ncomp keeps the leading count, else every component
	if !isempty(comps)
		for j in comps
			check_comps(j, ntotal)
		end
		jdx = comps
	elseif ncomp > 0 && ncomp < ntotal
		jdx = collect(1:ncomp)
	else
		jdx = collect(1:ntotal)
	end

	x = collect(1:length(jdx))

	#############
	# Counting  #
	#############

	# a variable is selected on a component when its loading there is not zero
	counts = [count(!iszero, view(loadings, :, j)) for j in jdx]

	# the fraction reads more easily than the count over many variables, since it does
	# not depend on knowing p
	y = asfraction ? counts ./ p : Float64.(counts)

	# the components are named by their index when no names were given
	if isempty(compnames)
		names = ["$(j)" for j in jdx]
	else
		names = compnames[jdx]
	end

	return x, y, names
end
