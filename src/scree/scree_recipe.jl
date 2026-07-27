##############
# SCREE PLOT #
##############

"""
	Recipe for scree plots.
"""
# mutable struct ScreePlot{AbstractType}
#     args::Any
# end

# screeplot(args...; kw...) = RecipesBase.plot(ScreePlot{typeof(args[1])}(args); kw...)

@userplot ScreePlot

@recipe function f(h::ScreePlot;
	barcolor = "#bdd7e7",
	linecolor_ = "#2171b5",
	showline = true)
	# check types of the input arguments
	if length(h.args) != 3 || !(typeof(h.args[1]) <: AbstractVector) ||
	   !(typeof(h.args[2]) <: AbstractVector) || !(typeof(h.args[3]) <: AbstractVector)
		error("Scree Plots should be given three vectors.  Got: $(typeof(h.args))")
	end

	#############
	# Arguments #
	#############
	# get arguments
	x, y, compnames = h.args

	# check the lengths of the input arguments
	if length(x) != length(y) || length(compnames) != length(x)
		error("Scree Plots should be given vectors of equal length.  Got: $(length(x)), $(length(y)), $(length(compnames))")
	end

	###################
	# Axis attributes #
	###################

	# the bars start at zero, so the axis does too, with a little headroom on top so the
	# line and its markers are not clipped against the frame
	y_max = 1.1 * maximum(y)

	# set a default value for an attribute with `-->`
	xlabel --> "Component"
	ylabel --> "Value"

	markerstrokewidth --> 0.3

	bottom_margin --> (0, :mm)
	right_margin --> (3, :mm)

	guidefontsize --> 15
	fontfamily --> "Helvetica"

	size --> (650, 550)

	# set up the subplots
	legend --> false
	ylims --> (0, y_max)
	grid --> :y
	gridwidth --> 0.7
	gridalpha --> 0.2

	tickfontsize := 8
	tick_direction := :out

	# the components are few, so they are always ticked by name
	xticks --> (x, compnames)

	##########
	# Bars   #
	##########
	@series begin
		seriestype := :bar
		fillcolor := barcolor
		linecolor := barcolor
		label := ""

		x, y
	end

	##########
	# Line   #
	##########
	# a line riding the tops of the bars, drawn by default, since it carries the eye
	# down the scree to the elbow better than the bars alone. It is turned off with
	# `showline = false`
	if showline
		@series begin
			seriestype := :path
			markershape := :circle
			markersize --> 5
			markercolor := linecolor_
			linecolor := linecolor_
			linewidth --> 2
			label := ""

			x, y
		end
	end
end