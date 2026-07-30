############################
# GROUPED CORRELATION PLOT #
############################


"""
	Recipe for grouped correlation plots.
"""

@userplot GroupedCorrelationPlot

@recipe function f(h::GroupedCorrelationPlot;
	hierarchycolor = "#737373",
	boundarycolor = :grey,
	boundarywidth = 0.5,
	showfractions = true,
	showlabels = true,
	labelwrap = true,
	labelcapacity = 80,
	labelfontsize = 8)

	# check types of the input arguments
	if length(h.args) != 4 || !(typeof(h.args[1]) <: AbstractMatrix) ||
	   !(typeof(h.args[2]) <: AbstractVector) ||
	   !(typeof(h.args[3]) <: AbstractVector) ||
	   !(typeof(h.args[4]) <: AbstractVector)
		error("Grouped Correlation Plots should be given a matrix and three vectors.  Got: $(typeof(h.args))")
	end

	#############
	# Arguments #
	#############

	z, variable_names, levelnames, spans = h.args
	n = size(z, 1)
	nlevels = length(spans)

	if size(z, 2) != n || length(variable_names) != n
		error("Grouped Correlation Plots should be given a square matrix matching its variable names.  Got: $(size(z)) for $(length(variable_names)) names")
	end

	if nlevels == 0 || length(levelnames) != nlevels
		error("Grouped Correlation Plots should be given one name and set of spans per hierarchy level.  Got: $(length(levelnames)), $(nlevels)")
	end

	###################
	# Axis attributes #
	###################

	# group names use separate label lanes rather than ordinary ticks. The broadest
	# group is outermost and every more specific level moves inward toward the heatmap,
	# so the hierarchy reads class, subclass, and then deeper levels
	deepest = spans[end]
	tickpos = [span.center for span in deepest]

	# repeated nested labels refer to different parent groups. Qualify only those
	# labels with their complete path so every displayed group name is unambiguous
	function spantext(span, level_spans)
		repeated = count(other -> other.label == span.label, level_spans) > 1
		name = repeated ? join(span.path, " › ") : span.label
		showfractions ?
			"$(name) ($(round(100 * span.fraction, digits = 1))%)" :
			name
	end

	# wrap a label according to the fraction of the axis occupied by its group. This
	# keeps long subclass names inside their own region instead of placing one name on
	# top of the next. Long words are split as well, so the rule is not language- or
	# naming-convention dependent
	function wraptext(label, fraction)
		maxchars = max(6, floor(Int, labelcapacity * fraction))
		words = String[]

		for word in split(label)
			characters = collect(word)

			for first in 1:maxchars:length(characters)
				last = min(first + maxchars - 1, length(characters))
				push!(words, String(characters[first:last]))
			end
		end

		lines = String[]
		line = ""

		for word in words
			candidate = isempty(line) ? word : "$(line) $(word)"

			if isempty(line) || length(candidate) <= maxchars
				line = candidate
			else
				push!(lines, line)
				line = word
			end
		end

		!isempty(line) && push!(lines, line)
		join(lines, "\n")
	end

	function displaytext(span, level_spans)
		label = spantext(span, level_spans)
		labelwrap ? wraptext(label, span.fraction) : label
	end

	ticktext = [spantext(span, deepest) for span in deepest]

	xlabel --> "Variables grouped by $(join(levelnames, " / "))"
	ylabel --> "Variables grouped by $(join(levelnames, " / "))"

	xticks --> (showlabels ? false : (tickpos, ticktext))
	yticks --> (showlabels ? false : (tickpos, ticktext))
	xrotation --> 90

	guidefontsize --> 12
	tickfontsize --> labelfontsize
	fontfamily --> "Helvetica"

	right_margin --> (8, :mm)
	bottom_margin --> (10, :mm)
	left_margin --> (10, :mm)

	size --> (900, 800)
	aspect_ratio --> :equal

	legend := false
	colorbar --> true
	colorbar_title --> "Correlation"
	clims --> (-1, 1)
	grid := false
	framestyle --> :box

	# each hierarchy level gets its own label lane. The broadest class sits farthest
	# from the heatmap and the most specific class sits nearest it
	step = max(1.0, 0.045 * n)
	pad = showlabels ? (nlevels + 0.75) * step : 0.0

	xlims --> (0.5 - pad, n + 0.5)
	ylims --> (0.5 - pad, n + 0.5)

	###########################
	# Grouped correlation map #
	###########################

	@series begin
		seriestype := :heatmap

		# these canonical attributes are the recipe defaults for the standard Plots
		# aliases c = :RdBu and clim = (-1, 1)
		seriescolor --> :RdBu

		collect(1:n), collect(1:n), z
	end

	########################
	# Hierarchy boundaries #
	########################

	# boundaries of the broad classes are heavier than boundaries of their nested
	# classes. The lines cross the map in both directions, making every diagonal block
	# and its share of the matrix immediately visible
	for depth in nlevels:-1:1
		bounds = [span.last + 0.5 for span in spans[depth] if span.last < n]

		if !isempty(bounds)
			vx = Float64[]
			vy = Float64[]
			hx = Float64[]
			hy = Float64[]

			for bound in bounds
				append!(vx, [bound, bound, NaN])
				append!(vy, [0.5, n + 0.5, NaN])
				append!(hx, [0.5, n + 0.5, NaN])
				append!(hy, [bound, bound, NaN])
			end

			@series begin
				seriestype := :path
				linecolor := boundarycolor
				linewidth := boundarywidth + 0.6 * (nlevels - depth)
				linealpha := 0.8
				primary := false
				label := ""

				vx, vy
			end

			@series begin
				seriestype := :path
				linecolor := boundarycolor
				linewidth := boundarywidth + 0.6 * (nlevels - depth)
				linealpha := 0.8
				primary := false
				label := ""

				hx, hy
			end
		end
	end

	####################
	# Hierarchy labels #
	####################

	if showlabels
		for depth in 1:nlevels
			distance = (nlevels - depth + 1) * step
			pos = 0.5 - distance
			text = [displaytext(span, spans[depth]) for span in spans[depth]]

			# every group name is centered on the portion of the axis that it owns.
			# There are deliberately no external bracket lines, so long names cannot
			# collide with hierarchy decoration

			@series begin
				seriestype := :scatter
				markershape := :none
				markeralpha := 0
				markersize := 0
				primary := false
				label := ""
				series_annotations := [
					(s, labelfontsize, hierarchycolor, :center) for s in text
				]

				[span.center for span in spans[depth]],
				fill(pos, length(spans[depth]))
			end

			@series begin
				seriestype := :scatter
				markershape := :none
				markeralpha := 0
				markersize := 0
				primary := false
				label := ""
				series_annotations := [
					(s, labelfontsize, hierarchycolor, :center, 90.0) for s in text
				]

				fill(pos, length(spans[depth])),
				[span.center for span in spans[depth]]
			end
		end
	end
end
