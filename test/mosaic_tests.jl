# mosaic_tests.jl — image and attribute tests for the mosaic plot.

@testset "mosaic plot" begin

    datadir = joinpath(@__DIR__, "data")
    refdir = joinpath(@__DIR__, "ref")

    counts = Helium.readhe(joinpath(datadir, "mosaic_counts.he"))

    rn = ["low", "mid", "high"]
    cn = ["A", "B", "C", "D"]

    #############
    # Image     #
    #############

    testpng = joinpath(@__DIR__, "mosaic_test.png")
    plot_mosaic(counts; rownames = rn, colnames = cn)
    savefig(testpng)

    img_ref = FileIO.load(joinpath(refdir, "mosaic_ref.png"))
    img_test = FileIO.load(testpng)

    # the tile count labels ride an invisible scatter that GR does not place reproducibly,
    # so the image is compared with a small tolerance, as with biplot and sparsity
    @test size(img_test) == size(img_ref)
    frac_diff = sum(img_test .!= img_ref) / length(img_ref)
    @test frac_diff < 0.02

    rm(testpng; force = true)

    #####################
    # Attributes        #
    #####################

    # recompute the geometry so the series can be matched by what they carry
    x, w, bottoms, heights, cts, condprobs, jointprobs,
    colmarginals, coltotalprob, _, _, _ =
        get_mosaic_coords(counts; rownames = rn, colnames = cn)

    plt = plot_mosaic(counts; rownames = rn, colnames = cn)
    series = plt.series_list

    r = length(rn)

    # one bar series per row of the table, each labelled with its row name. Match them by
    # label rather than by count, since the bar seriestype is expanded by the pipeline
    bylabel = Dict(s[:label] => s for s in series if s[:label] in rn)
    @test haskey(bylabel, "low")
    @test haskey(bylabel, "mid")
    @test haskey(bylabel, "high")

    # each bar's tops are the running total of the rows at or below it, so the topmost row
    # of the table reaches the full height of its column and the bottom row is the shortest
    top(s) = maximum(filter(!isnan, s[:y]))
    @test top(bylabel["low"]) ≈ maximum(bottoms[1, :] .+ heights[1, :])

    # the widths are set per column, so the bar_width vector matches the column marginals
    lowbar = bylabel["low"]
    @test lowbar[:bar_width] ≈ w

    # a different mode changes the labels but not the geometry: the bars sit in the same
    # place whatever number they carry
    plt_total = plot_mosaic(counts; rownames = rn, colnames = cn, mode = :total)
    bylabel_t = Dict(s[:label] => s for s in plt_total.series_list if s[:label] in rn)
    @test top(bylabel_t["low"]) ≈ top(bylabel["low"])

    # a bad mode and a bad marginals value are refused by the recipe
    @test_throws ErrorException plot_mosaic(counts; rownames = rn, colnames = cn, mode = :nonsense)
    @test_throws ErrorException plot_mosaic(counts; rownames = rn, colnames = cn, marginals = :nonsense)
end