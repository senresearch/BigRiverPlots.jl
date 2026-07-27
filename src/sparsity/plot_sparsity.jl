#=
plot_sparsity takes a matrix of loadings, so it is not tied to any one model, though
only the models with an L1 penalty have a sparsity to show. It counts the variables each
component keeps nonzero and draws them as bars, so how hard the penalty bit, component by
component, reads at a glance.

The models with an L1 penalty pass the field their penalty acts on:

	spc       plot_sparsity(m.loadings)
	pmd       plot_sparsity(m.v)                # the variable side; m.u for the sample side
	splsda    plot_sparsity(m.loadings_X)
	scca      plot_sparsity(m.u)                # the X side; m.v for the Y side

The dense models (pca, plskern, plsda, cca) select every variable on every component, so
their sparsity plot would be a flat row of full bars and is not drawn.

PMD penalizes BOTH factors, so it has a sparsity on each side: `m.v` counts the variables
kept, `m.u` the samples kept. Sparse CCA likewise has a side each in `m.u` and `m.v`.

With `asfraction = true` the bars carry the fraction of the variables selected rather than
the count, which reads more easily when the variables are many.

Everything else is a plot attribute, so it is passed straight to the plot:

	plot_sparsity(m.loadings; compnames = ["SPC 1", "SPC 2"], title = "sparse PCA")

=#


"""
plot_sparsity(loadings::Matrix{Float64}; ncomp::Int = 0, compnames::Vector{String} = String[],
			  asfraction::Bool = false, kwargs...)
Generates a bar plot of the number of variables each component of a penalized model keeps nonzero.
## Arguments
- `loadings` is a matrix of loadings, variables (rows) by components (columns), from a
  model with an L1 penalty.
- `ncomp` is the number of leading components to keep, default is `0` for all of them.
- `compnames` is a vector of names, one per component, default is `String[]` in which
  case the components are named by their index. They are given here rather than as
  `xticks` because they are subset along with the counts.
- `asfraction` draws the fraction of the variables selected rather than the count,
  default is `false`.
"""
function plot_sparsity(loadings::Matrix{Float64}; comps::Vector{Int} = Int[], ncomp::Int = 0,
	compnames::Vector{String} = String[], asfraction::Bool = false,
	kwargs...)
	# get coordinates ready for plotting
	x, y, names = get_sparsity_coords(loadings; comps = comps, ncomp = ncomp, compnames = compnames,
		asfraction = asfraction)
	sparsityplot(x, y, names; kwargs...)
end


"""
plot_sparsity!(loadings::Matrix{Float64}; ncomp::Int = 0, compnames::Vector{String} = String[],
			   asfraction::Bool = false, kwargs...)
Adds a bar plot of the number of variables each component of a penalized model keeps nonzero to the current plot.
## Arguments
- `loadings` is a matrix of loadings, variables (rows) by components (columns), from a
  model with an L1 penalty.
- `ncomp` is the number of leading components to keep, default is `0` for all of them.
- `compnames` is a vector of names, one per component, default is `String[]` in which
  case the components are named by their index. They are given here rather than as
  `xticks` because they are subset along with the counts.
- `asfraction` draws the fraction of the variables selected rather than the count,
  default is `false`.
"""
function plot_sparsity!(loadings::Matrix{Float64}; comps::Vector{Int} = Int[], ncomp::Int = 0,
	compnames::Vector{String} = String[], asfraction::Bool = false,
	kwargs...)
	# get coordinates ready for plotting
	x, y, names = get_sparsity_coords(loadings; comps = comps, ncomp = ncomp, compnames = compnames,
		asfraction = asfraction)
	sparsityplot!(x, y, names; kwargs...)
end
