######################
# JIVE VARIANCE PLOT #
######################

"""
	Recipe for JIVE variance explained plots.
"""
# mutable struct JiveVariancePlot{AbstractType}
#     args::Any
# end

# jivevarianceplot(args...; kw...) = RecipesBase.plot(JiveVariancePlot{typeof(args[1])}(args); kw...)

@userplot JiveVariancePlot

@recipe function f(h::JiveVariancePlot;
	jointcolor = "#333333",
	individualcolor = "#6e6e6e",
	residualcolor = "#a6a6a6")
	# check types of the input arguments
	if length(h.args) != 4 || !(typeof(h.args[1]) <: AbstractVector) ||
	   !(typeof(h.args[2]) <: AbstractVector) || !(typeof(h.args[3]) <: AbstractVector) ||
	   !(typeof(h.args[4]) <: AbstractVector)
		error("JIVE Variance Plots should be given four vectors.  Got: $(typeof(h.args))")
	end

	#############
	# Arguments #
	#############
	# get arguments
	varJ, varI, varR, blocknames = h.args

	# check the lengths of the input arguments
	if length(varJ) != length(varI) || length(varI) != length(varR) ||
	   length(varR) != length(blocknames)
		error("JIVE Variance Plots should be given vectors of equal length.  Got: $(length(varJ)), $(length(varI)), $(length(varR)), $(length(blocknames))")
	end

	k = length(varJ)

	###################
	# Axis attributes #
	###################

	# set a default value for an attribute with `-->`
	xlabel --> "Data block"
	ylabel --> "Proportion of variation"

	bottom_margin --> (0, :mm)
	right_margin --> (3, :mm)

	guidefontsize --> 15
	fontfamily --> "Helvetica"

	size --> (650, 550)

	# set up the subplots
	# the three fractions sum to one, so the axis runs zero to one and the bars are read
	# as the whole of each block's variation split three ways. The legend is set outside,
	# since the bars fill the axes to the top
	legend --> :outertopright
	ylims --> (0, 1)
	grid --> :y
	gridwidth --> 0.7
	gridalpha --> 0.2

	tickfontsize := 8
	tick_direction := :out

	# the blocks are few, so they are always ticked by name
	xticks --> (1:k, blocknames)

	#####################################
	# Stacked bars, residual at the base #
	#####################################
	# the three parts are stacked as running totals, so each bar reaches the height of the
	# parts below it plus its own. Residual sits at the base, individual on top of it, and
	# joint on top of both, which reads the block from what is unexplained up to what is
	# shared. Drawn joint last so it is the topmost segment

	# residual, from zero
	@series begin
		seriestype := :bar
		bar_width := 0.7
		fillcolor := residualcolor
		linecolor := :black
		linewidth := 0.3
		label := "Residual"

		1:k, varR
	end

	# individual, stacked on the residual
	@series begin
		seriestype := :bar
		bar_width := 0.7
		fillcolor := individualcolor
		linecolor := :black
		linewidth := 0.3
		label := "Individual"
		fillrange := varR

		1:k, varR .+ varI
	end

	# joint, stacked on the residual and the individual
	@series begin
		seriestype := :bar
		bar_width := 0.7
		fillcolor := jointcolor
		linecolor := :black
		linewidth := 0.3
		label := "Joint"
		fillrange := varR .+ varI

		1:k, varR .+ varI .+ varJ
	end
end