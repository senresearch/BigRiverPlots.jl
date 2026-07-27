################
# MOSAIC PLOT  #
################

"""
	Recipe for mosaic plots.
"""

@userplot MosaicPlot

@recipe function f(h::MosaicPlot;
	mosaiccolors = ["#3182bd", "#fd8d3c", "#74c476", "#9e9ac8", "#969696"],
	tilelinecolor = :white,
	mode = :count,
	marginals = :none,
	showlabels = true,
	labelcolor = :white,
	labelsize = 9,
	labelmintile = 0.06,
	marginalsize = 9,
	marginalcolor = "#333333",
	marginaloffset = 0.03)
	# check types of the input arguments
	if length(h.args) != 12
		error("Mosaic Plots should be given twelve arguments.  Got: $(length(h.args))")
	end

	#############
	# Arguments #
	#############
	x, w, bottoms, heights, counts, condprobs, jointprobs,
	colmarginals, coltotalprob, rownames, colnames, yticks_ = h.args

	r, c = size(heights)

	if !(mode in (:count, :conditional, :total))
		error("Mosaic Plots mode should be :count, :conditional or :total.  Got: $(mode)")
	end
	if !(marginals in (:none, :count, :probability))
		error("Mosaic Plots marginals should be :none, :count or :probability.  Got: $(marginals)")
	end

	# the label a tile carries depends on the mode: the raw count, the conditional
	# probability of the cell within its column, or its share of the whole table
	tilevals = mode === :count       ? counts     :
	           mode === :conditional ? condprobs  :
	                                    jointprobs

	# counts print as integers, probabilities to two places
	fmt(v) = mode === :count ? string(round(Int, v)) : string(round(v, digits = 2))

	###################
	# Axis attributes #
	###################

	xtop = maximum(x .+ w ./ 2)
	ytop = maximum(bottoms .+ heights)

	# extra headroom for the marginal strip, growing with the offset that pushes it out, so
	# the numbers always clear the tiles below them
	yhead = marginals === :none ? 0.01 : marginaloffset + 0.04

	# set a default value for an attribute with `-->`
	xlabel --> "Column"
	ylabel --> "Row"

	bottom_margin --> (0, :mm)
	right_margin --> (3, :mm)

	guidefontsize --> 15
	fontfamily --> "Helvetica"

	size --> (650, 550)

	# the tiles carry the reading, so the frame keeps its ticks but drops the grid: the row
	# and column names are what the plot is read by
	legend --> :outertopright
	grid --> false
	framestyle --> :grid

	xlims --> (-0.01, xtop + 0.01)
	ylims --> (-0.01, ytop + yhead)

	tickfontsize := 10
	tick_direction := :out

	xticks --> (x, colnames)
	yticks --> (yticks_, rownames)

	#################
	# The tiles     #
	#################
	# one series per row of the table, each drawn as bars of differing width sitting on the
	# rows below it. The first row of the table is the topmost series, so the picture reads
	# the way the table does
	for i in 1:r
		@series begin
			seriestype := :bar
			bar_width := w
			fillcolor := mosaiccolors[mod1(i, length(mosaiccolors))]
			linecolor := tilelinecolor
			linewidth := 1.0
			label := rownames[i]
			fillrange := bottoms[i, :]
			markershape := :none

			x, bottoms[i, :] .+ heights[i, :]
		end
	end

	#################
	# Tile labels   #
	#################
	# the chosen value written in the middle of each tile, riding an invisible scatter. A
	# tile smaller than `labelmintile` in either direction is left bare, since a label
	# would not fit
	if showlabels
		lx = Float64[]; ly = Float64[]; lt = String[]
		for j in 1:c, i in 1:r
			if heights[i, j] > labelmintile && w[j] > labelmintile
				push!(lx, x[j])
				push!(ly, bottoms[i, j] + heights[i, j] / 2)
				push!(lt, fmt(tilevals[i, j]))
			end
		end
		if !isempty(lx)
			@series begin
				seriestype := :scatter
				markershape := :none
				markeralpha := 0
				markerstrokewidth := 0
				primary := false
				series_annotations := [(s, labelsize, labelcolor, :center) for s in lt]
				lx, ly
			end
		end
	end

	#################
	# Top marginals #
	#################
	# one value per column, sitting a distance `marginaloffset` above the tallest tile: the
	# column count, or the marginal probability P(x). The offset is a push in data space, so
	# it moves the strip clear of the bars whether or not the plot is later permuted
	if marginals !== :none
		mvals = marginals === :count ? colmarginals : coltotalprob
		mfmt(v) = marginals === :count ? string(round(Int, v)) : string(round(v, digits = 2))
		mtext = [mfmt(v) for v in mvals]

		@series begin
			seriestype := :scatter
			markershape := :none
			markeralpha := 0
			markerstrokewidth := 0
			primary := false
			series_annotations := [(s, marginalsize, marginalcolor, :center) for s in mtext]
			x, fill(ytop + marginaloffset, c)
		end
	end
end