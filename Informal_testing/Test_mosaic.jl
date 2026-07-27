# Test_mosaic.jl — informal check of the mosaic plot, across its three modes and the
# marginal strip.
#
# Best run from the REPL so the windows stay up:
#   julia> include("Informal_testing/Test_mosaic.jl")
#
# (needs Plots and BigRiverPlots in the active environment)

using Plots
using BigRiverPlots


# ===========================================================================
# DATA
# ===========================================================================

# a three by four contingency table: three row categories against four column categories.
# the columns differ in total, so the mosaic columns come out at noticeably different
# widths, and each column splits differently between the three rows
counts = Float64[30 10  5  2
                 12 40  8  3
                  4  6 25 20]

rn = ["low", "mid", "high"]
cn = ["A", "B", "C", "D"]

total = sum(counts)

println("the table (rows: level, columns: group):")
println("           A    B    C    D")
for i in 1:3
    println("    ", rpad(rn[i], 5),
            lpad(Int(counts[i, 1]), 4), lpad(Int(counts[i, 2]), 5),
            lpad(Int(counts[i, 3]), 5), lpad(Int(counts[i, 4]), 5))
end
println()

# the quantities the three modes should be showing, to compare against the tiles
println("column marginals P(x): ", round.(vec(sum(counts, dims = 1)) ./ total, digits = 3))
println("P(level | A)         : ", round.(counts[:, 1] ./ sum(counts[:, 1]), digits = 3))
println("joint of the corner  : ", round(counts[1, 1] / total, digits = 3), "  (low, A)")
println()

# ===========================================================================
# THE THREE MODES
# ===========================================================================

# mode = :count — the raw counts, the default
display(plot_mosaic(counts;
                    mode = :count,
                    rownames = rn, colnames = cn,
                    xlabel = "Group", ylabel = "Level",
                    title = "counts"))

# mode = :conditional — P(y|x). Each column reads as the split of that group across the
# three levels. Same geometry as the count plot, different labels
display(plot_mosaic(counts;
                    rownames = rn, colnames = cn,
                    mode = :conditional,
                    xlabel = "Group", ylabel = "Level",
                    title = "conditional  P(level | group)"))

# mode = :total — each tile as its share of the whole table, the joint probability. The
# twelve tiles should sum to one
display(plot_mosaic(counts;
                    rownames = rn, colnames = cn,
                    mode = :total,
                    xlabel = "Group", ylabel = "Level",
                    title = "joint  P(level, group)"))

# ===========================================================================
# THE MARGINAL STRIP
# ===========================================================================

# marginals = :count — the column totals along the top
display(plot_mosaic(counts;
                    rownames = rn, colnames = cn,
                    marginals = :count,
                    xlabel = "Group", ylabel = "Level",
                    title = "counts, with column totals on top"))

# marginals = :probability — the marginal P(x) along the top. These should match the
# column marginals printed above
display(plot_mosaic(counts;
                    rownames = rn, colnames = cn,
                    mode = :conditional, marginals = :probability,
                    xlabel = "Group", ylabel = "Level",
                    title = "conditional, with P(x) on top"))

display(plot_mosaic(counts;
                    rownames = rn, colnames = cn,
                    mode = :total, marginals = :probability,
                    xlabel = "Group", ylabel = "Level",
                    title = "joint, with P(x) on top"))    



plot_mosaic(counts;
            rownames = rn, colnames = cn,
            mode = :total, marginals = :probability,
            permute = (:x, :y),
            xpad = 0.02,             # gap between columns
            ypad = 0.025,            # gap between stacked tiles
            marginaloffset = 0.10,   # push the marginals clear of the bars
            labelmintile = 0.03,     # smaller tiles keep their labels; raise to blank more
            legend = :outertopright,
            xlabel = "Group", ylabel = "Level",
            title = "joint, with P(x) on top")                    
# ===========================================================================
# THE STYLING KNOBS
# ===========================================================================

# a colour per row, dark labels large enough to read, the tile borders picked out
display(plot_mosaic(counts;
                    rownames = rn, colnames = cn,
                    mode = :total, marginals = :count,
                    mosaiccolors = ["#08519c", "#6baed6", "#c6dbef"],
                    tilelinecolor = :black,
                    labelcolor = :black,
                    labelsize = 12,
                    marginalcolor = "#d94801",
                    xlabel = "Group", ylabel = "Level",
                    title = "restyled"))

# labels off entirely: mode still sets what a label would be, but none is drawn
display(plot_mosaic(counts;
                    rownames = rn, colnames = cn,
                    showlabels = false,
                    xlabel = "Group", ylabel = "Level",
                    title = "no tile labels"))

# ===========================================================================
# HORIZONTAL, WITHOUT TOUCHING THE RECIPE
# ===========================================================================

# a mosaic of the transpose is the flipped plot, and it conditions the other way: the
# columns become the levels and the split within each is P(group | level)
display(plot_mosaic(permutedims(counts);
                    rownames = cn, colnames = rn,
                    mode = :conditional,
                    xlabel = "Level", ylabel = "Group",
                    title = "transpose: P(group | level)"))

# ===========================================================================
# THE GUARDS
# ===========================================================================

println("--- guards ---")

# a rownames vector of the wrong length
try
    plot_mosaic(counts; rownames = ["only one"], colnames = cn)
    println("!! expected an error for a short rownames vector, none thrown")
catch e
    println("short rownames vector : ", e)
end

# a colnames vector of the wrong length
try
    plot_mosaic(counts; rownames = rn, colnames = ["A", "B", "C"])
    println("!! expected an error for too few colnames, none thrown")
catch e
    println("wrong colname count   : ", e)
end

# a negative count
try
    plot_mosaic(Float64[1 -2 3 4; 5 6 7 8; 9 10 11 12]; rownames = rn, colnames = cn)
    println("!! expected an error for a negative count, none thrown")
catch e
    println("negative count        : ", e)
end

# an all zero table
try
    plot_mosaic(zeros(3, 4); rownames = rn, colnames = cn)
    println("!! expected an error for an all zero table, none thrown")
catch e
    println("all zero table        : ", e)
end

# a bad mode
try
    plot_mosaic(counts; rownames = rn, colnames = cn, mode = :nonsense)
    println("!! expected an error for a bad mode, none thrown")
catch e
    println("bad mode              : ", e)
end

# a bad marginals value
try
    plot_mosaic(counts; rownames = rn, colnames = cn, marginals = :nonsense)
    println("!! expected an error for a bad marginals value, none thrown")
catch e
    println("bad marginals         : ", e)
end

println()
println("done — count, conditional and total should share one geometry and differ only")
println("in the numbers in the tiles; each conditional column should sum to one.")