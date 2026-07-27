#=
plot_loadings takes a matrix of loadings, so it is not tied to any one model. Every
model of BigRiverEssence stores one, already held as variables (rows) by components
(columns), so unlike the scores none of them need transposing here:

	pca       plot_loadings(m.loadings; ntop = 20)
	spc       plot_loadings(m.loadings; nonzero = true, loadingsstyle = :sticks)
	pmd       plot_loadings(m.v; nonzero = true, loadingsstyle = :sticks)
	plskern   plot_loadings(m.P; ntop = 20)
	plsda     plot_loadings(m.loadings_X; ntop = 20)
	splsda    plot_loadings(m.loadings_X; nonzero = true, loadingsstyle = :sticks)
	cca       plot_loadings(m.xproj)
	scca      plot_loadings(m.u; nonzero = true, loadingsstyle = :sticks)
	jive      plot_loadings(m.U[i])

The models with an L1 penalty (spc, pmd, splsda, scca) are given `nonzero = true`,
since most of their loadings sit exactly at zero, and `loadingsstyle = :sticks`, since a stem
reads sparsity better than a bar. The dense models are given `ntop` instead, to keep
the variable axis legible.

The Y side of the two block models is drawn the same way, from `m.loadings_Y`,
`m.yproj` or `m.v`.

Everything else is a plot attribute, so it is passed straight to the plot and needs no
argument of its own. Naming the component in the label, for instance:

	plot_loadings(m.loadings; comp = 2, ylabel = "Loading on PC 2 (18.4%)")

=#


"""
plot_loadings(loadings::Matrix{Float64}; comp::Int = 1, varnames::Vector{String} = String[],
			  nonzero::Bool = false, ntop::Int = 0, kwargs...)
Generates a bar plot of the variable loadings of one component of a fitted model.
## Arguments
- `loadings` is the matrix of loadings, variables (rows) by components (columns).
- `comp` is the component whose loadings are drawn, default is `1`.
- `varnames` is a vector of names, one per variable, default is `String[]` in which
  case the variables are named by their index. They are given here rather than as
  `xticks` because they are subset along with the loadings.
- `nonzero` keeps only the variables whose loading is not zero, default is `false`,
  which is what the models with an L1 penalty need.
- `ntop` keeps only the `ntop` variables of largest absolute loading, default is `0`
  for all of them, which is what the dense models need over many variables.
"""
function plot_loadings(loadings::Matrix{Float64}; comp::Int = 1,
	varnames::Vector{String} = String[],
	nonzero::Bool = false, ntop::Int = 0, kwargs...)
	# get coordinates ready for plotting
	x, y, names = get_loadings_coords(loadings; comp = comp, varnames = varnames,
		nonzero = nonzero, ntop = ntop)
	loadingsplot(x, y, names; kwargs...)
end


"""
plot_loadings!(loadings::Matrix{Float64}; comp::Int = 1, varnames::Vector{String} = String[],
			   nonzero::Bool = false, ntop::Int = 0, kwargs...)
Adds a bar plot of the variable loadings of one component of a fitted model to the current plot.
## Arguments
- `loadings` is the matrix of loadings, variables (rows) by components (columns).
- `comp` is the component whose loadings are drawn, default is `1`.
- `varnames` is a vector of names, one per variable, default is `String[]` in which
  case the variables are named by their index. They are given here rather than as
  `xticks` because they are subset along with the loadings.
- `nonzero` keeps only the variables whose loading is not zero, default is `false`,
  which is what the models with an L1 penalty need.
- `ntop` keeps only the `ntop` variables of largest absolute loading, default is `0`
  for all of them, which is what the dense models need over many variables.
"""
function plot_loadings!(loadings::Matrix{Float64}; comp::Int = 1,
	varnames::Vector{String} = String[],
	nonzero::Bool = false, ntop::Int = 0, kwargs...)
	# get coordinates ready for plotting
	x, y, names = get_loadings_coords(loadings; comp = comp, varnames = varnames,
		nonzero = nonzero, ntop = ntop)
	loadingsplot!(x, y, names; kwargs...)
end
