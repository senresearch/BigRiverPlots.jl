############
# VIP PLOT #
############

"""
	Recipe for VIP plots.
"""
# mutable struct VipPlot{AbstractType}
#     args::Any
# end

# vipplot(args...; kw...) = RecipesBase.plot(VipPlot{typeof(args[1])}(args); kw...)

@userplot VipPlot

@recipe function f(h::VipPlot;
	vipcolor = :black,
	vipedgecolor = :grey,
	thresholdcolor = :red,
	threshold = 1.0,
	thresholdline = true,
	maxnames = 30)
	# check types of the input arguments
	if length(h.args) != 3 || !(typeof(h.args[1]) <: AbstractVector) ||
	   !(typeof(h.args[2]) <: AbstractVector) || !(typeof(h.args[3]) <: AbstractVector)
		error("VIP Plots should be given three vectors.  Got: $(typeof(h.args))")
	end

	#############
	# Arguments #
	#############
	# get arguments
	x, y, varnames = h.args

	# check the lengths of the input arguments
	if length(x) != length(y) || length(varnames) != length(x)
		error("VIP Plots should be given vectors of equal length.  Got: $(length(x)), $(length(y)), $(length(varnames))")
	end

	n = length(y)

	###################
	# Axis attributes #
	###################

	# the VIP runs along the x-axis from zero to a little above the largest score, so
	# the threshold line and the longest bar are not clipped against the frame
	x_max = 1.1 * max(maximum(y), threshold)

	# set a default value for an attribute with `-->`
	xlabel --> "VIP"
	ylabel --> "Variable (sorted by VIP)"

	bottom_margin --> (0, :mm)
	left_margin --> (10, :mm)

	guidefontsize --> 15
	fontfamily --> "Helvetica"

	size --> (600, 550)

	# set up the subplots
	legend --> false
	xlims --> (0, x_max)
	grid --> :x
	gridwidth --> 0.7
	gridalpha --> 0.2

	tickfontsize := 8
	tick_direction := :out

	# the names are only legible while there are few enough of them to fit, and past
	# that there is no room for a tick per variable, so the y-axis is left bare and the
	# sorted bars read as a curve. The order is largest at the top, so the ticks are
	# reversed to match the reversed bars below
	if n <= maxnames
		yticks --> (1:n, reverse(varnames))
	else
		yticks --> false
	end

	##########
	# Bars   #
	##########
	# horizontal bars, one per variable, sorted so the largest sits at the top. The
	# values are reversed because a horizontal bar plot counts its categories up from
	# the bottom, and the sort ran from the largest down
	@series begin
		seriestype := :bar
		orientation := :horizontal
		bar_width := 1.0
		fillcolor := vipcolor
		linecolor := vipedgecolor
		label := ""

		x, reverse(y)
	end

	####################
	# Threshold line   #
	####################
	# the vertical line at one, drawn by default, since a variable is read as important
	# by whether its bar reaches past it. It is turned off with `thresholdline = false`
	if thresholdline
		@series begin
			seriestype := :vline
			linecolor := thresholdcolor
			linestyle := :dash
			linewidth --> 1.5
			label := ""
			primary := false

			[threshold]
		end
	end
end