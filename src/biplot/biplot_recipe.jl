###########
# BIPLOT  #
###########

"""
	Recipe for biplots.
"""
# mutable struct BiPlot{AbstractType}
#     args::Any
# end

# biplot(args...; kw...) = RecipesBase.plot(BiPlot{typeof(args[1])}(args); kw...)

@userplot BiPlot

@recipe function f(h::BiPlot;
	origincolor = :lightgrey,
	arrowcolor = "#252525",
	ellipse = true,
	nstd = 2.5,
	arrowlabels = true)
	# check types of the input arguments
	if length(h.args) != 4 || !(typeof(h.args[1]) <: AbstractMatrix) ||
	   !(typeof(h.args[2]) <: AbstractVector) || !(typeof(h.args[3]) <: AbstractMatrix) ||
	   !(typeof(h.args[4]) <: AbstractVector)
		error("Biplots should be given two matrices and two vectors.  Got: $(typeof(h.args))")
	end
	# Note: group may be empty, in which case every observation is drawn in one series
	# and no ellipse is traced.

	#############
	# Arguments #
	#############
	# get arguments
	sxy, group, axy, varnames = h.args

	# check the dimensions of the input arguments
	if size(sxy, 2) != 2 || size(axy, 2) != 2
		error("Biplots should be given two columns of scores and two of arrows.  Got: $(size(sxy, 2)), $(size(axy, 2))")
	end

	if size(axy, 1) != length(varnames)
		error("Biplots should be given an arrow per name.  Got: $(size(axy, 1)) arrows for $(length(varnames)) names")
	end

	if !isempty(group) && length(group) != size(sxy, 1)
		error("Biplots should be given a group of the same length as the observations.  Got: $(length(group)) for $(size(sxy, 1))")
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

	marker --> 5
	markerstrokewidth --> 0.3

	bottom_margin --> (10, :mm)
	left_margin --> (10, :mm)

	guidefontsize --> 15
	fontfamily --> "Helvetica"

	size --> (900, 550)

	# set up the subplots
	# the legend is placed outside the axes, since the arrows reach into every corner
	# of the cloud and would sit under a legend placed within it
	legend --> (length(vLevels) > 1 ? :outertopright : false)
	legend_foreground_color --> :white
	link := :both
	grid --> true

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
			markerstrokecolor := :black
			label := ""

			# get the seriescolor passed by the user
			color --> :steelblue

			sxy[:, 1], sxy[:, 2]
		end
	else
		# one series per level, which gives categorical colors and one legend entry
		# per class rather than the continuous colorbar a marker_z would give
		for (ci, lvl) in enumerate(vLevels)
			idx = findall(g -> g == lvl, group)
			@series begin
				seriestype := :scatter
				markerstrokecolor := :black

				# the color is pinned to the index of the level, so that the ellipse
				# traced below can be given the same one
				seriescolor := ci
				label := string(lvl)

				sxy[idx, 1], sxy[idx, 2]
			end
		end
	end

	############################
	# Confidence ellipses      #
	############################
	# one ellipse per class, in the color of its points, so the spread of a class reads
	# at a glance and an observation outside its own ellipse stands out
	if ellipse && !isempty(vLevels)
		for (ci, lvl) in enumerate(vLevels)
			idx = findall(g -> g == lvl, group)

			# a class of one or two observations has no covariance worth tracing, so it
			# is left without an ellipse rather than failing the whole plot
			if length(idx) < 3
				continue
			end

			ex, ey = get_ellipse_coords(sxy[idx, 1], sxy[idx, 2]; nstd = nstd)

			@series begin
				seriestype := :path
				linecolor := ci
				linewidth --> 2
				linealpha --> 0.7
				markershape := :none
				markersize := 0
				markeralpha := 0
				label := ""
				primary := false

				ex, ey
			end
		end
	end

	#################
	# Arrows        #
	#################
	# one arrow per variable, from the origin along its loading: the direction says
	# which component the variable drives, the length how strongly, and the points
	# lying in the direction of an arrow are those high in that variable
	for v in 1:size(axy, 1)
		@series begin
			seriestype := :path
			arrow --> :arrow
			linecolor := arrowcolor
			linewidth --> 1
			markershape := :none
			label := ""
			primary := false

			[0.0, axy[v, 1]], [0.0, axy[v, 2]]
		end
	end

	#####################
	# Arrow labels      #
	#####################
	# the names are set just past the tip of each arrow, and are only legible while
	# there are few enough of them, so past that the arrows go unnamed. They are drawn
	# as an invisible scatter carrying `series_annotations`, rather than through the
	# plot level `annotations` attribute, since GR mishandles the latter from a recipe
	if arrowlabels && size(axy, 1) <= 30
		@series begin
			seriestype := :scatter
			markeralpha := 0
			markersize := 0
			label := ""
			primary := false
			annotationfontsize := 7
			annotationcolor := arrowcolor
			series_annotations := [varnames[v] for v in 1:size(axy, 1)]

			[1.12 * axy[v, 1] for v in 1:size(axy, 1)],
			[1.12 * axy[v, 2] for v in 1:size(axy, 1)]
		end
	end
end