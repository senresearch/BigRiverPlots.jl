#=
plot_mosaic takes a contingency table, so it is not tied to any one model. The width of
each column is the share of the whole table that column holds, the marginal P(x), and the
height of each tile within it is the conditional P(y|x), so the area of a tile is the
joint probability of its cell and the marginal and the conditional are both read from the
one picture.

The geometry is the same whatever is written in the tiles. Three modes choose that:

    mode = :count         the raw count of each cell
    mode = :conditional   the conditional probability P(y|x), the tile's share of its column
    mode = :total         the joint probability, the tile's share of the whole table

A strip along the top can show the column margins, either as counts or as the marginal
probability P(x), or be left off:

    marginals = :none         nothing along the top
    marginals = :count        the total of each column
    marginals = :probability  the marginal probability of each column

The gaps between the tiles are set separately for the two directions, `xpad` between the
columns and `ypad` between the stacked tiles, and `marginaloffset` sets how far the top
strip sits above the bars.

A cross tabulation of any two categorical variables is drawn the same way, whatever its
shape. Everything else is a plot attribute, so it is passed straight to the plot:

    plot_mosaic(counts; rownames = rn, colnames = cn, mode = :total,
                marginals = :probability, title = "joint")

=#


"""
plot_mosaic(counts::Matrix{Float64}; rownames::Vector{String} = String[],
            colnames::Vector{String} = String[], mode::Symbol = :count,
            marginals::Symbol = :none, xpad::Float64 = 0.02, ypad::Float64 = 0.02,
            kwargs...)
Generates a mosaic plot of a contingency table, the area of each tile proportional to its count.
## Arguments
- `counts` is the contingency table, one row per row category and one column per column
  category, holding counts or any non negative weights.
- `rownames` is a vector of names, one per row, default is `String[]` in which case the
  rows are named by their index. They are given here rather than as `yticks` because the
  plot places them against the tiles rather than at even spacing.
- `colnames` is a vector of names, one per column, default is `String[]` in which case the
  columns are named by their index.
- `mode` is what each tile is labelled with, default is `:count`. `:count` writes the raw
  count, `:conditional` the conditional probability `P(y|x)`, and `:total` the joint
  probability, the cell's share of the whole table.
- `marginals` is what the strip along the top shows, default is `:none`. `:count` writes
  the total of each column and `:probability` the marginal probability of each column.
- `xpad` is the gap left between the columns, default is `0.02`.
- `ypad` is the gap left between the stacked tiles within a column, default is `0.02`.
"""
function plot_mosaic(counts::Matrix{Float64};
	rownames::Vector{String} = String[],
	colnames::Vector{String} = String[],
	mode::Symbol = :count, marginals::Symbol = :none,
	xpad::Float64 = 0.02, ypad::Float64 = 0.02, kwargs...)
	# get coordinates ready for plotting
	x, w, bottoms, heights, cts, cp, jp, cm, ctp, rn, cn, yt =
		get_mosaic_coords(counts; rownames = rownames, colnames = colnames,
			xpad = xpad, ypad = ypad)
	mosaicplot(x, w, bottoms, heights, cts, cp, jp, cm, ctp, rn, cn, yt;
		mode = mode, marginals = marginals, kwargs...)
end


"""
plot_mosaic!(counts::Matrix{Float64}; rownames::Vector{String} = String[],
             colnames::Vector{String} = String[], mode::Symbol = :count,
             marginals::Symbol = :none, xpad::Float64 = 0.02, ypad::Float64 = 0.02,
             kwargs...)
Adds a mosaic plot of a contingency table to the current plot.
## Arguments
- `counts` is the contingency table, one row per row category and one column per column
  category, holding counts or any non negative weights.
- `rownames` is a vector of names, one per row, default is `String[]` in which case the
  rows are named by their index.
- `colnames` is a vector of names, one per column, default is `String[]` in which case the
  columns are named by their index.
- `mode` is what each tile is labelled with, default is `:count`. `:count` writes the raw
  count, `:conditional` the conditional probability `P(y|x)`, and `:total` the joint
  probability, the cell's share of the whole table.
- `marginals` is what the strip along the top shows, default is `:none`. `:count` writes
  the total of each column and `:probability` the marginal probability of each column.
- `xpad` is the gap left between the columns, default is `0.02`.
- `ypad` is the gap left between the stacked tiles within a column, default is `0.02`.
"""
function plot_mosaic!(counts::Matrix{Float64};
	rownames::Vector{String} = String[],
	colnames::Vector{String} = String[],
	mode::Symbol = :count, marginals::Symbol = :none,
	xpad::Float64 = 0.02, ypad::Float64 = 0.02, kwargs...)
	# get coordinates ready for plotting
	x, w, bottoms, heights, cts, cp, jp, cm, ctp, rn, cn, yt =
		get_mosaic_coords(counts; rownames = rownames, colnames = colnames,
			xpad = xpad, ypad = ypad)
	mosaicplot!(x, w, bottoms, heights, cts, cp, jp, cm, ctp, rn, cn, yt;
		mode = mode, marginals = marginals, kwargs...)
end