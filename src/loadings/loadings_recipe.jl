##################
# LOADINGS PLOT  #
##################

"""
	Recipe for loadings plots.
"""
# mutable struct LoadingsPlot{AbstractType}
#     args::Any
# end

# loadingsplot(args...; kw...) = RecipesBase.plot(LoadingsPlot{typeof(args[1])}(args); kw...)

@userplot LoadingsPlot

@recipe function f(h::LoadingsPlot;
	origincolor = "#737373",
	loadingscolor = "#4292c6",
	loadingsstyle = :bar)
	# check types of the input arguments
	if length(h.args) != 3 || !(typeof(h.args[1]) <: AbstractVector) ||
	   !(typeof(h.args[2]) <: AbstractVector) || !(typeof(h.args[3]) <: AbstractVector)
		error("Loadings Plots should be given three vectors.  Got: $(typeof(h.args))")
	end

	#############
	# Arguments #
	#############
	# get arguments
	x, y, varnames = h.args

	# check the lengths of the input arguments
	if length(x) != length(y) || length(varnames) != length(x)
		error("Loadings Plots should be given vectors of equal length.  Got: $(length(x)), $(length(y)), $(length(varnames))")
	end

	###################
	# Axis attributes #
	###################

	# the loadings are signed, so the axis is padded symmetrically about zero and the
	# reader can compare a positive contribution against a negative one
	y_max = 1.15 * maximum(abs, y)

	# set a default value for an attribute with `-->`
	xlabel --> "Variable"
	ylabel --> "Loading"

	markerstrokewidth --> 0.3

	bottom_margin --> (0, :mm)
	right_margin --> (3, :mm)

	guidefontsize --> 15
	fontfamily --> "Helvetica"

	size --> (650, 550)

	# set up the subplots
	legend --> false
	link := :both
	ylims --> (-y_max, y_max)
	grid --> :y
	gridwidth --> 0.7
	gridalpha --> 0.2

	tickfontsize := 8
	tick_direction := :out

	# the names are only legible while there are few enough of them to fit, so past
	# that the variables keep the numeric ticks the backend chooses
	if length(varnames) <= 30
		xticks --> (x, varnames)
		xrotation --> 90
	end

	####################
	# Horizontal line  #
	####################
	@series begin
		seriestype := :hline
		linecolor := origincolor
		primary := false
		# alpha := 0.5
		[0]
	end

	###################
	# Loadings values #
	###################
	@series begin
		seriestype := loadingsstyle
		markershape --> :circle
		markersize --> 3

		# get the seriescolor passed by the user
		linecolor --> loadingscolor
		color --> loadingscolor

		x, y
	end
end