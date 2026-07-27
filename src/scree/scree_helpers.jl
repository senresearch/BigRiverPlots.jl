#=
List of the scree helpers functions
- get_scree_coords
	Returns the per component values of a fitted model, ready for plotting as a scree,
	together with the names of the components they belong to.

=#


"""
get_scree_coords(values::AbstractVector; ncomp::Int = 0,
				 compnames::Vector{String} = String[], cumulative::Bool = false) =>

Returns the per component values of a fitted model, ready for plotting as a scree,
together with the names of the components they belong to.

## Arguments
- `values` is a vector of one value per component: the variances of a PCA or a sparse
  PCA, the weights `d` of a penalized matrix decomposition or a sparse CCA, or the
  canonical correlations of a CCA. Any per component quantity can be given, since the
  scree only asks that it fall off from the first component to the last.
- `ncomp` is the number of leading components to keep, default is `0` for all of them.
  A scree is read for its elbow, which is near the front, so the long tail can be
  dropped without losing the shape.
- `compnames` is a vector of names, one per component, default is `String[]` for no
  names, in which case the components are named by their index. They are subset along
  with the values, which is why they are given here rather than passed to the plot as
  ticks.
- `cumulative` returns the running total of the values rather than the values
  themselves, default is `false`. On the proportion of variance of a PCA this gives the
  rising curve read against a threshold, the companion to the falling bars.

## Output
- `x` vector contains the positions of the components kept, one to the number kept.
- `y` vector contains the values of the components kept, cumulated when asked.
- `names` vector contains the names of the components kept, or their indices as strings
  when no `compnames` were given.

"""
function get_scree_coords(values::AbstractVector; ncomp::Int = 0,
	compnames::Vector{String} = String[], cumulative::Bool = false)

	n = length(values)

	# check that a name was given for every component, when any were given
	if !isempty(compnames) && length(compnames) != n
		error("Scree compnames should be given one per component.  Got: $(length(compnames)) for $(n)")
	end

	#######################
	# Components to keep  #
	#######################

	# every component is kept when none were asked for, else the leading ncomp of them
	keep = (ncomp > 0 && ncomp < n) ? ncomp : n

	jdx = collect(1:keep)

	x = collect(1:keep)

	# the running total is taken over the components kept, so a truncated scree still
	# reads its cumulative curve up to the last component shown
	y = cumulative ? cumsum(values[jdx]) : collect(values[jdx])

	# the components are named by their index when no names were given
	if isempty(compnames)
		names = ["$(j)" for j in jdx]
	else
		names = compnames[jdx]
	end

	return x, y, names
end
