#=
plot_pairs takes a matrix of scores, so it is not tied to any one model. It crosses
every component against every other, which is the view the scores plot cannot give:
where that draws one pair, this draws them all, and a cluster that separates on no
single pair but does on some third one shows up here.

Every model of BigRiverEssence produces such a matrix, some directly and some after a
projection or a transposition, exactly as for the scores plot:

	pca       plot_pairs(pca_transform(m, X); comps = [1, 2, 3])
	spc       plot_pairs(((X .- m.mean') ./ m.scale') * m.loadings; comps = [1, 2, 3])
	pmd       plot_pairs(m.u; comps = [1, 2, 3])
	plskern   plot_pairs(m.T)
	plsda     plot_pairs(m.variates_X; group = y)
	splsda    plot_pairs(m.variates_X; group = y)
	cca       plot_pairs(permutedims(cca_transform(m, Z, :x)))
	scca      plot_pairs(permutedims(Z) * m.u)
	jive      plot_pairs(permutedims(m.S))

Note that cca, scca and jive hold the variables in ROWS and the observations in
COLUMNS, so their scores are transposed before being given here.

The grid is square in the number of components crossed, so it grows fast: four make
sixteen cells and six make thirty six. Three or four is usually as much as reads, and
`comps` is there to say which.

The cells are titled by the recipe, so a `title` given here would repeat once per cell
and is blanked. The grid takes a `plot_title` instead:

	plot_pairs(pca_transform(m, X); group = y, comps = [1, 2, 3],
			   plot_title = "PCA scores")

=#


"""
plot_pairs(scores::Matrix{Float64}; comps::Vector{Int} = Int[], group::AbstractVector = [],
		   compnames::Vector{String} = String[], kwargs...)
Generates a scatter matrix of the sample scores of a fitted model, crossing every component against every other.
## Arguments
- `scores` is the matrix of scores, observations (rows) by components (columns).
- `comps` is a vector naming the components to be crossed, default is `Int[]` for all
  of them. At least two are needed, and three or four is usually as much as reads.
- `group` is a vector of class labels, one per observation, used to color the points
  of the cells off the diagonal, default is `[]` for no grouping.
- `compnames` is a vector of names, one per component, default is `String[]` in which
  case the components are named by their index. They are given here rather than as
  labels because they are subset along with the scores, and because each names both a
  row and a column of the grid.
"""
function plot_pairs(scores::Matrix{Float64}; comps::Vector{Int} = Int[],
	group::AbstractVector = [], compnames::Vector{String} = String[],
	kwargs...)
	# get coordinates ready for plotting
	z, names = get_pairs_coords(scores; comps = comps, compnames = compnames)
	pairsplot(z, group, names; kwargs...)
end


"""
plot_pairs!(scores::Matrix{Float64}; comps::Vector{Int} = Int[], group::AbstractVector = [],
			compnames::Vector{String} = String[], kwargs...)
Adds a scatter matrix of the sample scores of a fitted model to the current plot.
## Arguments
- `scores` is the matrix of scores, observations (rows) by components (columns).
- `comps` is a vector naming the components to be crossed, default is `Int[]` for all
  of them. At least two are needed, and three or four is usually as much as reads.
- `group` is a vector of class labels, one per observation, used to color the points
  of the cells off the diagonal, default is `[]` for no grouping.
- `compnames` is a vector of names, one per component, default is `String[]` in which
  case the components are named by their index. They are given here rather than as
  labels because they are subset along with the scores, and because each names both a
  row and a column of the grid.
"""
function plot_pairs!(scores::Matrix{Float64}; comps::Vector{Int} = Int[],
	group::AbstractVector = [], compnames::Vector{String} = String[],
	kwargs...)
	# get coordinates ready for plotting
	z, names = get_pairs_coords(scores; comps = comps, compnames = compnames)
	pairsplot!(z, group, names; kwargs...)
end
