################
# SCORES PLOT  #
################

"""
	Recipe for scores plots.
"""
# mutable struct ScoresPlot{AbstractType}
#     args::Any
# end

# scoresplot(args...; kw...) = RecipesBase.plot(ScoresPlot{typeof(args[1])}(args); kw...)

@userplot ScoresPlot

@recipe function f(h::ScoresPlot;
	origincolor = :lightgrey)
	# check types of the input arguments
	if length(h.args) != 3 || !(typeof(h.args[1]) <: AbstractVector) ||
	   !(typeof(h.args[2]) <: AbstractVector) || !(typeof(h.args[3]) <: AbstractVector)
		error("Scores Plots should be given three vectors.  Got: $(typeof(h.args))")
	end
	# Note: group may be empty, in which case every observation is drawn in one series.

	#############
	# Arguments #
	#############
	# get arguments
	x, y, group = h.args

	# check the lengths of the input arguments
	if length(x) != length(y) || (!isempty(group) && length(group) != length(x))
		error("Scores Plots should be given vectors of equal length.  Got: $(length(x)), $(length(y)), $(length(group))")
	end

	##################
	# Group location #
	##################

	# get the levels of the grouping vector, one series is drawn per level
	vLevels = get_levels(group)

	###################
	# Axis attributes #
	###################

	# set a default value for an attribute with `-->`
	xlabel --> "Component 1"
	ylabel --> "Component 2"

	marker --> 6
	markerstrokewidth --> 0.3

	bottom_margin --> (0, :mm)
	right_margin --> (0, :mm)

	guidefontsize --> 15
	fontfamily --> "Helvetica"

	size --> (650, 550)

	# set up the subplots
	# a legend is only informative when the observations are split into classes
	legend --> (length(vLevels) > 1)
	link := :both
	grid := false

	tickfontsize := 8
	tick_direction := :out

	##################
	# Vertical line  #
	##################
	@series begin
		seriestype := :vline
		linecolor := origincolor
		primary := false
		# alpha := 0.5
		[0]
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

	#################
	# Scores values #
	#################
	if isempty(vLevels)
		# no grouping was requested, so every observation goes in one series
		@series begin
			seriestype := :scatter
			framestyle := :box
			markerstrokecolor := :black

			# get the seriescolor passed by the user
			color --> :steelblue

			x, y
		end
	else
		# one series per level, which gives categorical colors and one legend entry
		# per class rather than the continuous colorbar a marker_z would give
		for lvl in vLevels
			idx = findall(g -> g == lvl, group)
			@series begin
				seriestype := :scatter
				framestyle := :box
				markerstrokecolor := :black
				label := string(lvl)

				x[idx], y[idx]
			end
		end
	end
end