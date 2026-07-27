#=
plot_biplot takes a matrix of scores and a matrix of loadings, so it is not tied to any
one model. It draws the two together: the observations as points and the variables as
arrows from the origin, on the same pair of axes. Where the scores plot says which
samples group together and the loadings plot says which variables matter, the biplot
says WHICH VARIABLES DRIVE WHICH SAMPLES.

Every model of BigRiverEssence stores both, though the scores of some need a projection
or a transposition while the loadings never do:

	pca       plot_biplot(pca_transform(m, X), m.loadings; ntop = 10)
	spc       plot_biplot(((X .- m.mean') ./ m.scale') * m.loadings, m.loadings; nonzero = true)
	pmd       plot_biplot(m.u, m.v; nonzero = true)
	plskern   plot_biplot(m.T, m.P; ntop = 10)
	plsda     plot_biplot(m.variates_X, m.loadings_X; group = y, ntop = 10)
	splsda    plot_biplot(m.variates_X, m.loadings_X; group = y, nonzero = true)
	cca       plot_biplot(permutedims(cca_transform(m, Z, :x)), m.xproj)
	scca      plot_biplot(permutedims(Z) * m.u, m.u; nonzero = true)
	jive      plot_biplot(permutedims(m.S), m.U[i])

Note that cca, scca and jive hold the variables in ROWS and the observations in
COLUMNS, so their SCORES are transposed before being given here, while their LOADINGS
already read as variables by components and are given as they are.

The models with an L1 penalty (spc, pmd, splsda, scca) are given `nonzero = true`,
since the arrows of the variables they dropped have no length and only crowd the
origin. The dense models are given `ntop` instead, to keep the arrows from burying the
points.

Reading the figure: the DIRECTION of an arrow says which component the variable drives,
its LENGTH how strongly, two arrows pointing the same way are variables that vary
together, and the observations lying in the direction of an arrow are those high in
that variable. The arrows are scaled onto the cloud of points by a convention, so their
relative lengths mean something while their absolute lengths do not.

Everything else is a plot attribute, so it is passed straight to the plot:

	plot_biplot(pca_transform(m, X), m.loadings; group = y, ntop = 10,
				xlabel = "PC 1 (52.3%)", ylabel = "PC 2 (18.4%)", title = "PCA biplot")

=#


"""
plot_biplot(scores::Matrix{Float64}, loadings::Matrix{Float64}; comps::Tuple{Int, Int} = (1, 2),
			group::AbstractVector = [], varnames::Vector{String} = String[],
			nonzero::Bool = false, ntop::Int = 0, arrowscale::Float64 = 0.0, kwargs...)
Generates a biplot of a fitted model, drawing the observations as points and the variables as arrows.
## Arguments
- `scores` is the matrix of scores, observations (rows) by components (columns), which
  places the points.
- `loadings` is the matrix of loadings, variables (rows) by components (columns), which
  points the arrows. It should come from the same fitted model as `scores`.
- `comps` is a tuple naming the two components placed on the x and y axes, default is `(1, 2)`.
- `group` is a vector of class labels, one per observation, used to color the points
  and to trace one confidence ellipse per class, default is `[]` for no grouping.
- `varnames` is a vector of names, one per variable, default is `String[]` in which
  case the variables are named by their index. They are given here rather than as
  annotations because they are subset along with the arrows.
- `nonzero` keeps only the variables whose loading is not zero on at least one of the
  two components drawn, default is `false`, which is what the models with an L1 penalty need.
- `ntop` keeps only the `ntop` variables of longest arrow, default is `0` for all of
  them, which is what the dense models need over many variables.
- `arrowscale` is the factor the arrows are scaled by, default is `0.0` to scale them
  onto the cloud of points automatically.
"""
function plot_biplot(scores::Matrix{Float64}, loadings::Matrix{Float64};
	comps::Tuple{Int, Int} = (1, 2), group::AbstractVector = [],
	varnames::Vector{String} = String[],
	nonzero::Bool = false, ntop::Int = 0, arrowscale::Float64 = 0.0,
	kwargs...)
	# get coordinates ready for plotting
	sxy, axy, names = get_biplot_coords(scores, loadings; comps = comps,
		varnames = varnames, nonzero = nonzero,
		ntop = ntop, arrowscale = arrowscale)
	biplot(sxy, group, axy, names; kwargs...)
end


"""
plot_biplot!(scores::Matrix{Float64}, loadings::Matrix{Float64}; comps::Tuple{Int, Int} = (1, 2),
			 group::AbstractVector = [], varnames::Vector{String} = String[],
			 nonzero::Bool = false, ntop::Int = 0, arrowscale::Float64 = 0.0, kwargs...)
Adds a biplot of a fitted model to the current plot.
## Arguments
- `scores` is the matrix of scores, observations (rows) by components (columns), which
  places the points.
- `loadings` is the matrix of loadings, variables (rows) by components (columns), which
  points the arrows. It should come from the same fitted model as `scores`.
- `comps` is a tuple naming the two components placed on the x and y axes, default is `(1, 2)`.
- `group` is a vector of class labels, one per observation, used to color the points
  and to trace one confidence ellipse per class, default is `[]` for no grouping.
- `varnames` is a vector of names, one per variable, default is `String[]` in which
  case the variables are named by their index. They are given here rather than as
  annotations because they are subset along with the arrows.
- `nonzero` keeps only the variables whose loading is not zero on at least one of the
  two components drawn, default is `false`, which is what the models with an L1 penalty need.
- `ntop` keeps only the `ntop` variables of longest arrow, default is `0` for all of
  them, which is what the dense models need over many variables.
- `arrowscale` is the factor the arrows are scaled by, default is `0.0` to scale them
  onto the cloud of points automatically.
"""
function plot_biplot!(scores::Matrix{Float64}, loadings::Matrix{Float64};
	comps::Tuple{Int, Int} = (1, 2), group::AbstractVector = [],
	varnames::Vector{String} = String[],
	nonzero::Bool = false, ntop::Int = 0, arrowscale::Float64 = 0.0,
	kwargs...)
	# get coordinates ready for plotting
	sxy, axy, names = get_biplot_coords(scores, loadings; comps = comps,
		varnames = varnames, nonzero = nonzero,
		ntop = ntop, arrowscale = arrowscale)
	biplot!(sxy, group, axy, names; kwargs...)
end
