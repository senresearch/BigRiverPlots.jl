#=
plot_scores takes a matrix of scores, so it is not tied to any one model. Every model
of BigRiverEssence produces such a matrix, some directly and some after a projection
or a transposition:

	pca       plot_scores(pca_transform(m, X))
	spc       plot_scores(((X .- m.mean') ./ m.scale') * m.loadings)
	pmd       plot_scores(m.u)
	plskern   plot_scores(m.T)
	plsda     plot_scores(m.variates_X; group = y)
	splsda    plot_scores(m.variates_X; group = y)
	cca       plot_scores(permutedims(cca_transform(m, Z, :x)))
	scca      plot_scores(permutedims(Z) * m.u)
	jive      plot_scores(permutedims(m.S))

Note that cca, scca and jive hold the variables in ROWS and the observations in
COLUMNS, so their scores are transposed before being given here.

Note also that the `classes` field of a plsda or a splsda holds the unique labels, in
the column order of Y_dummy, and not one label per observation, so `y` is given to
`group` rather than `m.classes`.

Everything else is a plot attribute, so it is passed straight to the plot and needs no
argument of its own. Naming the components in the labels, for instance:

	plot_scores(pca_transform(m, X); group = y,
				xlabel = "PC 1 (52.3%)", ylabel = "PC 2 (18.4%)")

=#


"""
plot_scores(scores::Matrix{Float64}; comps::Tuple{Int, Int} = (1, 2),
			group::AbstractVector = [], kwargs...)
Generates a scatter plot of the sample scores of a fitted model.
## Arguments
- `scores` is the matrix of scores, observations (rows) by components (columns).
- `comps` is a tuple naming the two components placed on the x and y axes, default is `(1, 2)`.
- `group` is a vector of class labels, one per observation, used to color the points,
  default is `[]` for no grouping.
"""
function plot_scores(scores::Matrix{Float64}; comps::Tuple{Int, Int} = (1, 2),
	group::AbstractVector = [], kwargs...)
	# get coordinates ready for plotting
	x, y = get_scores_coords(scores; comps = comps)
	scoresplot(x, y, group; kwargs...)
end


"""
plot_scores!(scores::Matrix{Float64}; comps::Tuple{Int, Int} = (1, 2),
			 group::AbstractVector = [], kwargs...)
Adds a scatter plot of the sample scores of a fitted model to the current plot.
## Arguments
- `scores` is the matrix of scores, observations (rows) by components (columns).
- `comps` is a tuple naming the two components placed on the x and y axes, default is `(1, 2)`.
- `group` is a vector of class labels, one per observation, used to color the points,
  default is `[]` for no grouping.
"""
function plot_scores!(scores::Matrix{Float64}; comps::Tuple{Int, Int} = (1, 2),
	group::AbstractVector = [], kwargs...)
	# get coordinates ready for plotting
	x, y = get_scores_coords(scores; comps = comps)
	scoresplot!(x, y, group; kwargs...)
end
