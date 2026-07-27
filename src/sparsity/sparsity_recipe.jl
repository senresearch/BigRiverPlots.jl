#################
# SPARSITY PLOT #
#################

"""
	Recipe for sparsity plots.
"""
# mutable struct SparsityPlot{AbstractType}
#     args::Any
# end

# sparsityplot(args...; kw...) = RecipesBase.plot(SparsityPlot{typeof(args[1])}(args); kw...)

@userplot SparsityPlot

@recipe function f(h::SparsityPlot;
	sparsitycolor = "#807dba",
	labelcounts = true)
	# check types of the input arguments
	if length(h.args) != 3 || !(typeof(h.args[1]) <: AbstractVector) ||
	   !(typeof(h.args[2]) <: AbstractVector) || !(typeof(h.args[3]) <: AbstractVector)
		error("Sparsity Plots should be given three vectors.  Got: $(typeof(h.args))")
	end

	#############
	# Arguments #
	#############
	# get arguments
	x, y, compnames = h.args

	# check the lengths of the input arguments
	if length(x) != length(y) || length(compnames) != length(x)
		error("Sparsity Plots should be given vectors of equal length.  Got: $(length(x)), $(length(y)), $(length(compnames))")
	end

	###################
	# Axis attributes #
	###################

	# the count starts at zero, so the axis does too, with headroom on top so the count
	# written over the tallest bar is not clipped against the frame
	y_max = 1.15 * maximum(y)

	# set a default value for an attribute with `-->`
	xlabel --> "Component"
	ylabel --> "Variables selected"

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
		fillcolor := sparsitycolor
		linecolor := sparsitycolor
		label := ""

		x, y
	end

	####################
	# Count labels     #
	####################
	# the count written just above each bar, drawn by default, since the number selected
	# is the point of the plot and reading it off the axis is imprecise. It is turned off
	# with `labelcounts = false`, and is suppressed when the counts are fractions rather
	# than whole numbers
	if labelcounts && all(v -> v == round(v), y)
		@series begin
			seriestype := :scatter
			markeralpha := 0
			markersize := 0
			label := ""
			primary := false
			annotationfontsize := 9
			series_annotations := [string(Int(v)) for v in y]

			x, y .+ 0.04 * y_max
		end
	end
end