#=
List of the pairs helpers functions
- get_pairs_coords
	Returns the components of a matrix of scores to be crossed against one another,
	ready for plotting, together with the names they belong to.

=#


"""
get_pairs_coords(scores::Matrix{Float64}; comps::Vector{Int} = Int[],
				 compnames::Vector{String} = String[]) =>

Returns the components of a matrix of scores to be crossed against one another, ready
for plotting, together with the names they belong to.

## Arguments
- `scores` is the matrix of scores, observations (rows) by components (columns). Any
  set of sample coordinates can be given: the projected data of a PCA or a sparse PCA,
  the left factors of a penalized matrix decomposition, the X scores of a PLS
  regression, the X variates of a discriminant model, the canonical variates of a CCA,
  or the joint scores of a JIVE model.
- `comps` is a vector naming the components to be crossed, default is `Int[]` for all
  of them. The grid drawn is square in the number given, so it grows fast: four
  components make sixteen cells, and six make thirty six. Three or four is usually as
  much as reads.
- `compnames` is a vector of names, one per component of `scores`, default is
  `String[]` for no names, in which case the components are named by their index. They
  are subset along with the scores, following `comps`, which is why they are given here
  rather than passed to the plot as ticks.

## Output
- `z` matrix contains the scores of the components kept, observations (rows) by
  components (columns).
- `names` vector contains the names of the components kept, one per column of `z`.

"""
function get_pairs_coords(scores::Matrix{Float64}; comps::Vector{Int} = Int[],
	compnames::Vector{String} = String[])

	ncomp = size(scores, 2)

	# check that a name was given for every component, when any were given
	if !isempty(compnames) && length(compnames) != ncomp
		error("Pairs compnames should be given one per component.  Got: $(length(compnames)) for $(ncomp)")
	end

	#######################
	# Components to keep  #
	#######################

	# every component is crossed when none were named
	jdx = isempty(comps) ? collect(1:ncomp) : comps

	for j in jdx
		check_comps(j, ncomp)
	end

	# a grid needs two components to have anything off the diagonal to draw
	if length(jdx) < 2
		error("Pairs Plots should be given at least two components to cross.  Got: $(length(jdx))")
	end

	z = scores[:, jdx]

	# the components are named by their index when no names were given
	if isempty(compnames)
		names = ["$(j)" for j in jdx]
	else
		names = compnames[jdx]
	end

	return z, names
end
