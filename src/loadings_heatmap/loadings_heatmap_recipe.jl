##########################
# LOADINGS HEATMAP PLOT  #
##########################

"""
	Recipe for loadings heatmap plots.
"""
# mutable struct LoadingsHeatmapPlot{AbstractType}
#     args::Any
# end

# loadingsheatmapplot(args...; kw...) = RecipesBase.plot(LoadingsHeatmapPlot{typeof(args[1])}(args); kw...)

@userplot LoadingsHeatmapPlot

@recipe function f(h::LoadingsHeatmapPlot;
	heatmapcolor = :RdBu,
	maxnames = 40)
	# check types of the input arguments
	if length(h.args) != 3 || !(typeof(h.args[1]) <: AbstractMatrix) ||
	   !(typeof(h.args[2]) <: AbstractVector) || !(typeof(h.args[3]) <: AbstractVector)
		error("Loadings Heatmap Plots should be given a matrix and two vectors.  Got: $(typeof(h.args))")
	end

	#############
	# Arguments #
	#############
	# get arguments
	z, xnames, ynames = h.args

	# check the dimensions of the input arguments
	if size(z, 1) != length(ynames) || size(z, 2) != length(xnames)
		error("Loadings Heatmap Plots should be given a matrix matching its names.  Got: $(size(z)) for $(length(ynames)) variables and $(length(xnames)) components")
	end

	####################
	# Color attributes #
	####################

	# the loadings are signed, so the scale is centered at zero and padded symmetrically:
	# a selected variable then reads warm or cool by the sign of its loading, and one the
	# penalty dropped reads as the midtone of the diverging scheme
	z_max = maximum(abs, z)
	z_max = z_max == 0 ? 1.0 : z_max

	###################
	# Axis attributes #
	###################

	# set a default value for an attribute with `-->`
	xlabel --> "Component"
	ylabel --> "Variable"

	bottom_margin --> (0, :mm)
	right_margin --> (3, :mm)

	guidefontsize --> 15
	fontfamily --> "Helvetica"

	size --> (650, 550)

	# set up the subplots
	legend --> false
	grid --> false
	clims --> (-z_max, z_max)
	colorbar --> true
	color --> heatmapcolor

	tickfontsize := 8
	tick_direction := :out

	# the components are few, so they are always ticked by name
	xticks --> (1:length(xnames), xnames)

	# the variables are only legible while there are few enough of them to fit, so past
	# that they keep the numeric ticks the backend chooses
	if length(ynames) <= maxnames
		yticks --> (1:length(ynames), ynames)
	end

	###################
	# Loadings values #
	###################
	@series begin
		seriestype := :heatmap

		1:length(xnames), 1:length(ynames), z
	end
end