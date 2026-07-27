###############
# PAIRS PLOT  #
###############

"""
	Recipe for pairs plots.
"""
# mutable struct PairsPlot{AbstractType}
#     args::Any
# end

# pairsplot(args...; kw...) = RecipesBase.plot(PairsPlot{typeof(args[1])}(args); kw...)

@userplot PairsPlot

@recipe function f(h::PairsPlot;
	diagcolor = "#969696",
	diagbins = 20)
	# check types of the input arguments
	if length(h.args) != 3 || !(typeof(h.args[1]) <: AbstractMatrix) ||
	   !(typeof(h.args[2]) <: AbstractVector) || !(typeof(h.args[3]) <: AbstractVector)
		error("Pairs Plots should be given a matrix and two vectors.  Got: $(typeof(h.args))")
	end
	# Note: group may be empty, in which case every observation is drawn in one series.

	#############
	# Arguments #
	#############
	# get arguments
	z, group, compnames = h.args

	# check the dimensions of the input arguments
	if size(z, 2) != length(compnames)
		error("Pairs Plots should be given a matrix matching its names.  Got: $(size(z, 2)) components for $(length(compnames)) names")
	end

	if !isempty(group) && length(group) != size(z, 1)
		error("Pairs Plots should be given a group of the same length as the observations.  Got: $(length(group)) for $(size(z, 1))")
	end

	k = size(z, 2)

	##################
	# Group location #
	##################

	# get the levels of the grouping vector, one series is drawn per level per cell
	vLevels = get_levels(group)

	################
	# Cell limits  #
	################

	# every cell of a column shares an x scale, and every cell of a row shares a y
	# scale, so the grid reads as one figure rather than as k² independently zoomed
	# panels. The limits are forced per cell because the automatic linking does not
	# reach through a layout built series by series
	lims = map(1:k) do d
		lo, hi = extrema(view(z, :, d))
		pad = 0.05 * (hi - lo)
		pad = pad == 0 ? 1.0 : pad
		(lo - pad, hi + pad)
	end

	###################
	# Axis attributes #
	###################

	# set a default value for an attribute with `-->`
	guidefontsize --> 9
	fontfamily --> "Helvetica"

	size --> (700, 700)

	# set up the subplots
	layout := (k, k)
	link := :none
	grid --> false

	# a legend is only informative when the observations are split into classes, and
	# it is drawn once, outside the top right cell so it covers no data
	legend --> (length(vLevels) > 1 ? :outertopright : false)

	tickfontsize := 6
	tick_direction := :out

	left_margin --> (3, :mm)
	bottom_margin --> (3, :mm)

	##########
	# Cells  #
	##########

	for r in 1:k, c in 1:k

		if r == c
			###############################
			# Diagonal, the distribution  #
			###############################
			@series begin
				subplot := (r - 1) * k + c

				# a per cell title would repeat k² times, so the grid is titled once
				# with `plot_title` instead
				title := ""

				seriestype := :histogram
				bins := diagbins
				fillcolor := diagcolor
				linecolor := diagcolor
				fillalpha --> 0.6
				label := ""

				# the x scale matches the column, the y scale is a count of its own
				xlims := lims[c]

				# only the outer edge is labelled, so the inner cells stay clean
				xlabel := (r == k ? compnames[c] : "")
				ylabel := (c == 1 ? compnames[r] : "")

				z[:, c]
			end

		else
			##############################
			# Off diagonal, the scatter  #
			##############################
			if isempty(vLevels)
				# no grouping was requested, so every observation goes in one series
				@series begin
					subplot := (r - 1) * k + c
					title := ""

					seriestype := :scatter
					markersize --> 3
					markerstrokewidth --> 0.3
					markeralpha --> 0.6
					label := ""

					# get the seriescolor passed by the user
					color --> :steelblue

					xlims := lims[c]
					ylims := lims[r]

					xlabel := (r == k ? compnames[c] : "")
					ylabel := (c == 1 ? compnames[r] : "")

					z[:, c], z[:, r]
				end

			else
				for (ci, lvl) in enumerate(vLevels)
					idx = findall(g -> g == lvl, group)
					@series begin
						subplot := (r - 1) * k + c
						title := ""

						seriestype := :scatter
						markersize --> 3
						markerstrokewidth --> 0.3
						markeralpha --> 0.6

						# the color is pinned to the index of the level, or the palette
						# would advance from one cell to the next and a class would
						# change color across the grid
						seriescolor := ci

						# an empty label leaves the series out of the legend, so only
						# the top right cell writes one. It is off the diagonal for any
						# k of two or more, which the helper already requires
						label := (r == 1 && c == k) ? string(lvl) : ""

						xlims := lims[c]
						ylims := lims[r]

						xlabel := (r == k ? compnames[c] : "")
						ylabel := (c == 1 ? compnames[r] : "")

						z[idx, c], z[idx, r]
					end
				end
			end
		end
	end
end