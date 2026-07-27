#=
plot_loadings_heatmap takes a matrix of loadings, so it is not tied to any one model.
Every model of BigRiverEssence stores one, already held as variables (rows) by
components (columns), so none of them need transposing here:

	pca       plot_loadings_heatmap(m.loadings; ntop = 30)
	spc       plot_loadings_heatmap(m.loadings; nonzero = true)
	pmd       plot_loadings_heatmap(m.v; nonzero = true)
	plskern   plot_loadings_heatmap(m.P; ntop = 30)
	plsda     plot_loadings_heatmap(m.loadings_X; ntop = 30)
	splsda    plot_loadings_heatmap(m.loadings_X; nonzero = true)
	cca       plot_loadings_heatmap(m.xproj)
	scca      plot_loadings_heatmap(m.u; nonzero = true)
	jive      plot_loadings_heatmap(m.U[i])

The models with an L1 penalty (spc, pmd, splsda, scca) are given `nonzero = true`,
since most of their rows are zero on every component and leave the map a flat field of
the midtone. The dense models are given `ntop` instead, to keep the variable axis
legible.

Where the loadings plot draws ONE component, the heatmap draws them together, which is
what shows whether two components select the same variables, and with what sign.

The Y side of the two block models is drawn the same way, from `m.loadings_Y`,
`m.yproj` or `m.v`.

Everything else is a plot attribute, so it is passed straight to the plot and needs no
argument of its own:

	plot_loadings_heatmap(m.loadings; ntop = 30, title = "PCA loadings")

=#


"""
plot_loadings_heatmap(loadings::Matrix{Float64}; comps::Vector{Int} = Int[],
					  varnames::Vector{String} = String[], compnames::Vector{String} = String[],
					  nonzero::Bool = false, ntop::Int = 0, kwargs...)
Generates a heatmap of the variable loadings of every component of a fitted model.
## Arguments
- `loadings` is the matrix of loadings, variables (rows) by components (columns).
- `comps` is a vector naming the components to be drawn, default is `Int[]` for all of them.
- `varnames` is a vector of names, one per variable, default is `String[]` in which
  case the variables are named by their index. They are given here rather than as
  `yticks` because they are subset along with the loadings.
- `compnames` is a vector of names, one per component, default is `String[]` in which
  case the components are named by their index.
- `nonzero` keeps only the variables whose loading is not zero on at least one of the
  components drawn, default is `false`, which is what the models with an L1 penalty need.
- `ntop` keeps only the `ntop` variables of largest absolute loading over the components
  drawn, default is `0` for all of them, which is what the dense models need over many
  variables.
"""
function plot_loadings_heatmap(loadings::Matrix{Float64}; comps::Vector{Int} = Int[],
	varnames::Vector{String} = String[],
	compnames::Vector{String} = String[],
	nonzero::Bool = false, ntop::Int = 0, kwargs...)
	# get coordinates ready for plotting
	z, xnames, ynames = get_loadings_heatmap_coords(loadings; comps = comps,
		varnames = varnames,
		compnames = compnames,
		nonzero = nonzero, ntop = ntop)
	loadingsheatmapplot(z, xnames, ynames; kwargs...)
end


"""
plot_loadings_heatmap!(loadings::Matrix{Float64}; comps::Vector{Int} = Int[],
					   varnames::Vector{String} = String[], compnames::Vector{String} = String[],
					   nonzero::Bool = false, ntop::Int = 0, kwargs...)
Adds a heatmap of the variable loadings of every component of a fitted model to the current plot.
## Arguments
- `loadings` is the matrix of loadings, variables (rows) by components (columns).
- `comps` is a vector naming the components to be drawn, default is `Int[]` for all of them.
- `varnames` is a vector of names, one per variable, default is `String[]` in which
  case the variables are named by their index. They are given here rather than as
  `yticks` because they are subset along with the loadings.
- `compnames` is a vector of names, one per component, default is `String[]` in which
  case the components are named by their index.
- `nonzero` keeps only the variables whose loading is not zero on at least one of the
  components drawn, default is `false`, which is what the models with an L1 penalty need.
- `ntop` keeps only the `ntop` variables of largest absolute loading over the components
  drawn, default is `0` for all of them, which is what the dense models need over many
  variables.
"""
function plot_loadings_heatmap!(loadings::Matrix{Float64}; comps::Vector{Int} = Int[],
	varnames::Vector{String} = String[],
	compnames::Vector{String} = String[],
	nonzero::Bool = false, ntop::Int = 0, kwargs...)
	# get coordinates ready for plotting
	z, xnames, ynames = get_loadings_heatmap_coords(loadings; comps = comps,
		varnames = varnames,
		compnames = compnames,
		nonzero = nonzero, ntop = ntop)
	loadingsheatmapplot!(z, xnames, ynames; kwargs...)
end
