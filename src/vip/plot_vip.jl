#=
plot_vip takes a matrix of VIP scores, so it is not tied to any one model, though only
the discriminant models produce one. It sorts the variables by their Variable
Importance in Projection and lays them out as horizontal bars, the largest at the top,
with a dashed line at the threshold of one. Over many variables the sorted bars read as
a curve, and the number of important variables is where the curve crosses the line.

The VIP is defined for the discriminant models alone, and is read off the `vip`
function of BigRiverEssence:

	plsda     plot_vip(vip(m))
	splsda    plot_vip(vip(m))

`vip` returns a matrix of variables by components, cumulative through the components, so
its last column is the overall importance and is the one plotted by default. An earlier
component is read with `comp`.

The other models store no VIP, so they have no VIP plot. Their variable importance is
read from the loadings plot instead.

Everything else is a plot attribute, so it is passed straight to the plot. The x-axis
can be named for the number of components, as the model reports it:

	plot_vip(vip(m); xlabel = "VIP ($(m.ncomp) axes)", title = "Variable Importance in Projection")

=#


"""
plot_vip(vips::Matrix{Float64}; comp::Int = 0, varnames::Vector{String} = String[],
		 above::Bool = false, ntop::Int = 0, kwargs...)
Generates a horizontal bar plot of the Variable Importance in Projection of a discriminant model, sorted, with a threshold line at one.
## Arguments
- `vips` is the matrix of VIP scores, variables (rows) by components (columns), as
  returned by `vip` on a fitted plsda or splsda.
- `comp` is the component whose column is drawn, default is `0` for the last, the
  overall VIP.
- `varnames` is a vector of names, one per variable, default is `String[]` in which
  case the variables are named by their index. They are given here rather than as
  `yticks` because they are sorted and subset along with the scores. The plot hides
  them past a few dozen, since there is no room for a tick per variable.
- `above` keeps only the variables scoring above one, the usual threshold for an
  important variable, default is `false`.
- `ntop` keeps only the `ntop` variables of largest VIP, default is `0` for all of them.
"""
function plot_vip(vips::Matrix{Float64}; comp::Int = 0, varnames::Vector{String} = String[],
	above::Bool = false, ntop::Int = 0, kwargs...)
	# get coordinates ready for plotting
	x, y, names = get_vip_coords(vips; comp = comp, varnames = varnames, above = above,
		ntop = ntop)
	vipplot(x, y, names; kwargs...)
end


"""
plot_vip!(vips::Matrix{Float64}; comp::Int = 0, varnames::Vector{String} = String[],
		  above::Bool = false, ntop::Int = 0, kwargs...)
Adds a horizontal bar plot of the Variable Importance in Projection of a discriminant model to the current plot.
## Arguments
- `vips` is the matrix of VIP scores, variables (rows) by components (columns), as
  returned by `vip` on a fitted plsda or splsda.
- `comp` is the component whose column is drawn, default is `0` for the last, the
  overall VIP.
- `varnames` is a vector of names, one per variable, default is `String[]` in which
  case the variables are named by their index. They are given here rather than as
  `yticks` because they are sorted and subset along with the scores. The plot hides
  them past a few dozen, since there is no room for a tick per variable.
- `above` keeps only the variables scoring above one, the usual threshold for an
  important variable, default is `false`.
- `ntop` keeps only the `ntop` variables of largest VIP, default is `0` for all of them.
"""
function plot_vip!(vips::Matrix{Float64}; comp::Int = 0, varnames::Vector{String} = String[],
	above::Bool = false, ntop::Int = 0, kwargs...)
	# get coordinates ready for plotting
	x, y, names = get_vip_coords(vips; comp = comp, varnames = varnames, above = above,
		ntop = ntop)
	vipplot!(x, y, names; kwargs...)
end
