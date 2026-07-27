#=
plot_scree takes a vector of one value per component, so it is not tied to any one
model. It draws the value of each component as a bar, with a line riding their tops, so
the fall from the first component to the last shows where the elbow is and how many
components are worth keeping.

Only the models that store a per component strength have a scree to draw. Each passes
the field that measures the strength of its components:

	pca       plot_scree(m.variances)
	spc       plot_scree(m.variances)
	pmd       plot_scree(m.d)
	cca       plot_scree(m.corrs)
	scca      plot_scree(m.cors)
	jive      plot_scree(vcat(m.r, m.ri); compnames = ["joint"; ...])   # ranks, not a fall

The regression and discriminant models (plskern, plsda, splsda) store no per component
strength, so they have no scree.

For a PCA the proportion of variance can be given instead of the raw variance, and with
`cumulative = true` the rising curve read against a threshold is drawn rather than the
falling bars:

	plot_scree(m.propOFvar; cumulative = true, ylabel = "cumulative proportion")

Everything else is a plot attribute, so it is passed straight to the plot:

	plot_scree(m.variances; ncomp = 10, ylabel = "variance", title = "PCA scree")

=#


"""
plot_scree(values::AbstractVector; ncomp::Int = 0, compnames::Vector{String} = String[],
		   cumulative::Bool = false, kwargs...)
Generates a scree plot of the per component values of a fitted model, as bars with a line riding their tops.
## Arguments
- `values` is a vector of one value per component, such as `m.variances`, `m.d` or
  `m.corrs`.
- `ncomp` is the number of leading components to keep, default is `0` for all of them.
- `compnames` is a vector of names, one per component, default is `String[]` in which
  case the components are named by their index. They are given here rather than as
  `xticks` because they are subset along with the values.
- `cumulative` draws the running total of the values rather than the values themselves,
  default is `false`, useful on the proportion of variance of a PCA.
"""
function plot_scree(values::AbstractVector; ncomp::Int = 0,
	compnames::Vector{String} = String[], cumulative::Bool = false,
	kwargs...)
	# get coordinates ready for plotting
	x, y, names = get_scree_coords(values; ncomp = ncomp, compnames = compnames,
		cumulative = cumulative)
	screeplot(x, y, names; kwargs...)
end


"""
plot_scree!(values::AbstractVector; ncomp::Int = 0, compnames::Vector{String} = String[],
			cumulative::Bool = false, kwargs...)
Adds a scree plot of the per component values of a fitted model to the current plot.
## Arguments
- `values` is a vector of one value per component, such as `m.variances`, `m.d` or
  `m.corrs`.
- `ncomp` is the number of leading components to keep, default is `0` for all of them.
- `compnames` is a vector of names, one per component, default is `String[]` in which
  case the components are named by their index. They are given here rather than as
  `xticks` because they are subset along with the values.
- `cumulative` draws the running total of the values rather than the values themselves,
  default is `false`, useful on the proportion of variance of a PCA.
"""
function plot_scree!(values::AbstractVector; ncomp::Int = 0,
	compnames::Vector{String} = String[], cumulative::Bool = false,
	kwargs...)
	# get coordinates ready for plotting
	x, y, names = get_scree_coords(values; ncomp = ncomp, compnames = compnames,
		cumulative = cumulative)
	screeplot!(x, y, names; kwargs...)
end
