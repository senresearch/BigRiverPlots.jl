# generate_mosaic.jl — build the mosaic fixture and its reference image.
#
# Run once, by hand, to regenerate the fixture and the reference:
#   julia --project=. test/scripts/generate_mosaic.jl
#
# The mosaic takes a plain contingency table rather than a fitted model, so there is no
# model to seed or fit. The table is written straight to test/data/mosaic_counts.he, and
# the plot with the default attributes rendered to test/ref/mosaic_ref.png.

using WolfRiverPlots
using Plots
using Helium

#############
# The data  #
#############

# a three by four contingency table: three row categories against four column categories.
# the columns differ in total, so the columns come out at different widths and each splits
# differently between the three rows
counts = Float64[30 10  5  2
                 12 40  8  3
                  4  6 25 20]

######################
# Save the fixture   #
######################

datadir = joinpath(@__DIR__, "..", "data")
mkpath(datadir)

Helium.writehe(counts, joinpath(datadir, "mosaic_counts.he"))

######################
# Save the reference #
######################

refdir = joinpath(@__DIR__, "..", "ref")
mkpath(refdir)

# the default render, one bar per column split into three tiles, counts in each tile
plot_mosaic(counts;
            rownames = ["low", "mid", "high"],
            colnames = ["A", "B", "C", "D"])
savefig(joinpath(refdir, "mosaic_ref.png"))

println("generate_mosaic: wrote data/mosaic_counts.he, ref/mosaic_ref.png")