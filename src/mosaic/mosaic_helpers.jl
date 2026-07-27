"""
get_mosaic_coords(counts::Matrix{Float64}; rownames::Vector{String} = String[],
                  colnames::Vector{String} = String[], xpad::Float64 = 0.02,
                  ypad::Float64 = 0.02)
Splits a contingency table into the tile geometry of a mosaic plot.
## Arguments
- `counts` is the contingency table, one row per row category and one column per
  column category, holding counts or any non negative weights.
- `rownames` is a vector of names, one per row, default is `String[]` in which case
  the rows are named by their index.
- `colnames` is a vector of names, one per column, default is `String[]` in which case
  the columns are named by their index.
- `xpad` is the gap left between the columns, default is `0.02`.
- `ypad` is the gap left between the stacked tiles within a column, default is `0.02`.

## Output
- `x`, `w` are the centre and width of each column.
- `bottoms`, `heights` are the lower edge and height of every tile.
- `counts` is passed back through, so the recipe can label the tiles with the raw count.
- `condprobs` is the conditional probability of each cell within its column, P(y|x).
- `jointprobs` is each cell's count over the grand total, its share of the whole table.
- `colmarginals` is the total of each column, and `coltotalprob` its share of the grand
  total, so the top strip can show either the column count or the marginal P(x).
- `rnames`, `cnames`, `yticks` name the tiles and place the row ticks.
"""
function get_mosaic_coords(counts::Matrix{Float64};
	rownames::Vector{String} = String[],
	colnames::Vector{String} = String[],
	xpad::Float64 = 0.02, ypad::Float64 = 0.02)

	r, c = size(counts)

	if r < 1 || c < 1
		error("Mosaic Plots should be given a table with at least one row and one column.  Got: $(size(counts))")
	end

	if any(counts .< 0)
		error("Mosaic Plots should be given non negative counts.  Got a minimum of: $(minimum(counts))")
	end

	total = sum(counts)

	if total == 0
		error("Mosaic Plots should be given a table with some variation.  Got a table summing to zero.")
	end

	if !isempty(rownames) && length(rownames) != r
		error("Mosaic Plots should be given one rowname per row.  Got: $(length(rownames)), $(r)")
	end

	if !isempty(colnames) && length(colnames) != c
		error("Mosaic Plots should be given one colname per column.  Got: $(length(colnames)), $(c)")
	end

	###################
	# Column widths   #
	###################
	# the width of a column is the share of the whole table it holds, the marginal P(x), so
	# a column standing for a rare category is drawn narrow
	coltotals = vec(sum(counts, dims = 1))
	w = coltotals ./ total

	###################
	# Tile heights    #
	###################
	# within a column the heights are the conditional probabilities P(y|x), so each column
	# fills the axis whatever its width. A column holding nothing is left flat
	condprobs = zeros(r, c)
	for j in 1:c
		if coltotals[j] > 0
			condprobs[:, j] = counts[:, j] ./ coltotals[j]
		end
	end
	heights = condprobs

	###################
	# Joint probs     #
	###################
	# each cell over the grand total: its share of the whole table, the area of its tile
	jointprobs = counts ./ total

	###################
	# Column placing  #
	###################
	# the columns are laid left to right, each starting a gap of `xpad` after the one before
	x = zeros(c)
	acc = 0.0
	for j in 1:c
		x[j] = acc + w[j] / 2
		acc += w[j] + xpad
	end

	###################
	# Tile stacking   #
	###################
	# the rows are stacked from the bottom up in reverse, a gap of `ypad` between them, so
	# the first row of the table ends up at the top of the plot
	bottoms = zeros(r, c)
	for j in 1:c
		acc = 0.0
		for i in r:-1:1
			bottoms[i, j] = acc
			acc += heights[i, j] + ypad
		end
	end

	yticks = bottoms[:, 1] .+ heights[:, 1] ./ 2

	###################
	# Column marginals#
	###################
	# the count and the probability of each column, for the strip along the top
	colmarginals = coltotals
	coltotalprob = coltotals ./ total

	rnames = isempty(rownames) ? ["Row $(i)" for i in 1:r] : rownames
	cnames = isempty(colnames) ? ["Col $(j)" for j in 1:c] : colnames

	return x, w, bottoms, heights, counts, condprobs, jointprobs,
	       colmarginals, coltotalprob, rnames, cnames, yticks
end