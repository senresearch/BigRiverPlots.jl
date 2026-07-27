#=
List of the scores helpers functions
- get_scores_coords
	Returns the coordinates of two components of a matrix of scores, ready for
	plotting.

=#


"""
get_scores_coords(scores::Matrix{Float64}; comps::Tuple{Int, Int} = (1, 2)) =>

Returns the coordinates of two components of a matrix of scores, ready for plotting.

## Arguments
- `scores` is the matrix of scores, observations (rows) by components (columns). Any
  set of sample coordinates can be given: the projected data of a PCA or a sparse PCA,
  the left factors of a penalized matrix decomposition, the X scores of a PLS
  regression, the X variates of a discriminant model, the canonical variates of a CCA,
  or the joint scores of a JIVE model.
- `comps` is a tuple naming the two components placed on the x and y axes, default is `(1, 2)`.

## Output
- `x` vector contains the scores of the observations on the first component.
- `y` vector contains the scores of the observations on the second component.

"""
function get_scores_coords(scores::Matrix{Float64}; comps::Tuple{Int, Int} = (1, 2))

	check_comps(comps, size(scores, 2))
	i, j = comps

	x = scores[:, i]
	y = scores[:, j]

	return x, y
end
