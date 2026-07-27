##############################
# PREDICT OBSERVATIONS PLOT  #
##############################

"""
	Recipe for predicted versus observed plots.
"""
# mutable struct PredictObsPlot{AbstractType}
#     args::Any
# end

# predictobsplot(args...; kw...) = RecipesBase.plot(PredictObsPlot{typeof(args[1])}(args); kw...)

@userplot PredictObsPlot

@recipe function f(h::PredictObsPlot;
	pointcolor = "#3182bd",
	linecolor_ = "#737373",
	refline = true,
	showr2 = true)
	# check types of the input arguments
	if length(h.args) != 4 || !(typeof(h.args[1]) <: AbstractVector) ||
	   !(typeof(h.args[2]) <: AbstractVector) || !(typeof(h.args[3]) <: Tuple) ||
	   !(typeof(h.args[4]) <: Real)
		error("Predict Observations Plots should be given two vectors, a tuple and a number.  Got: $(typeof(h.args))")
	end

	#############
	# Arguments #
	#############
	# get arguments
	x, y, line, r2 = h.args

	# check the lengths of the input arguments
	if length(x) != length(y)
		error("Predict Observations Plots should be given vectors of equal length.  Got: $(length(x)), $(length(y))")
	end

	lo, hi = line

	###################
	# Axis attributes #
	###################

	# a little padding so the points at the extremes are not sat against the frame
	pad = 0.05 * (hi - lo)
	pad = pad == 0 ? 1.0 : pad

	# set a default value for an attribute with `-->`
	xlabel --> "Observed"
	ylabel --> "Predicted"

	marker --> 5
	markerstrokewidth --> 0.3

	bottom_margin --> (0, :mm)
	right_margin --> (3, :mm)

	guidefontsize --> 15
	fontfamily --> "Helvetica"

	size --> (600, 600)

	# set up the subplots
	# the axes share a range and the frame is square, so the forty five degree line sits
	# at a true forty five degrees and the eye can judge the scatter against it
	legend --> false
	link := :both
	aspect_ratio --> :equal
	xlims --> (lo - pad, hi + pad)
	ylims --> (lo - pad, hi + pad)
	grid --> true
	gridwidth --> 0.7
	gridalpha --> 0.2

	tickfontsize := 8
	tick_direction := :out

	####################
	# Reference line   #
	####################
	# the line of perfect prediction, drawn first so the points sit over it. A point on
	# the line was predicted exactly, one above it over predicted, one below under. It is
	# turned off with `refline = false`
	if refline
		@series begin
			seriestype := :path
			linecolor := linecolor_
			linestyle := :dash
			linewidth --> 1.5
            markershape := :none
			label := ""
			primary := false

			[lo, hi], [lo, hi]
		end
	end

	##################
	# The points     #
	##################
	@series begin
		seriestype := :scatter
		framestyle := :box
		markerstrokecolor := :black

		# get the seriescolor passed by the user
		color --> pointcolor

		x, y
	end

	####################
	# R squared        #
	####################
	# the coefficient of determination set in the upper left, drawn by default, since it
	# is the one number that says how close the fit is. It is turned off with
	# `showr2 = false`
	if showr2
		@series begin
			seriestype := :scatter
			markeralpha := 0
			markersize := 0
			label := ""
			primary := false
			annotationfontsize := 11
			series_annotations := [(("R² = $(round(r2, digits = 3))"), 11, :left, :top, linecolor_)]

			[lo + 0.05 * (hi - lo)], [hi - 0.05 * (hi - lo)]
		end
	end
end