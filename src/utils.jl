#=
List of the utils functions
- get_levels
	Returns the unique levels of a grouping vector, in order of first appearance,
	so that each class is drawn as its own series.
- check_comps
	Checks that a requested component index, or pair of component indices, exists in
	a fitted model.

=#


"""
get_levels(group::AbstractVector) =>

Returns the unique levels of a grouping vector, in order of first appearance.

## Arguments
- `group` is a vector of class labels, one per observation, or an empty vector when
  the observations are not grouped.

## Output
- `vLevels` vector contains the unique labels found in `group`, in order of first
  appearance, or an empty vector when `group` is empty. The recipes draw one series
  per level, which is what gives categorical colors and one legend entry per class.

"""
function get_levels(group::AbstractVector)

	# no grouping was requested, so there are no levels to split on
	if isempty(group)
		return []
	end

	# unique preserves the order of first appearance, so the legend follows the
	# order the classes appear in the data rather than an arbitrary sort
	vLevels = unique(group)

	return vLevels
end


"""
check_comps(comp::Int, ncomp::Int) =>

Checks that a requested component index exists in a fitted model.

## Arguments
- `comp` is the index of the single component to be drawn.
- `ncomp` is the number of components available in the fitted model.

## Output
- Nothing is returned. An error is thrown when the index falls outside `1:ncomp`, so
  that an out of range request fails with a clear message instead of a bounds error
  raised deep inside Plots. This is the method the plots of a single component need,
  such as the loadings plot.

"""
function check_comps(comp::Int, ncomp::Int)

	if comp < 1 || comp > ncomp
		error("Component should be in the range 1:$(ncomp).  Got: $(comp)")
	end

	return nothing
end


"""
check_comps(comps::Tuple{Int, Int}, ncomp::Int) =>

Checks that a requested pair of component indices exists in a fitted model.

## Arguments
- `comps` is a tuple naming the two components to be placed on the x and y axes.
- `ncomp` is the number of components available in the fitted model.

## Output
- Nothing is returned. An error is thrown when either index falls outside `1:ncomp`,
  so that an out of range request fails with a clear message instead of a bounds
  error raised deep inside Plots. This is the method the plots of two components
  need, such as the scores plot.

"""
function check_comps(comps::Tuple{Int, Int}, ncomp::Int)

	i, j = comps

	if i < 1 || i > ncomp || j < 1 || j > ncomp
		error("Components should be in the range 1:$(ncomp).  Got: $(comps)")
	end

	return nothing
end
