# predict_observations_tests.jl — image and attribute tests for the predict-observations plot.

@testset "predict observations plot" begin

    datadir = joinpath(@__DIR__, "data")
    refdir = joinpath(@__DIR__, "ref")

    observed = Helium.readhe(joinpath(datadir, "predict_observations_observed.he"))
    predicted = Helium.readhe(joinpath(datadir, "predict_observations_predicted.he"))

    # image test
    testpng = joinpath(@__DIR__, "predict_observations_test.png")
    plot_predict_observations(observed, predicted)
    savefig(testpng)

    img_ref = FileIO.load(joinpath(refdir, "predict_observations_ref.png"))
    img_test = FileIO.load(testpng)

    # the R squared annotation rides an invisible scatter that GR does not place
    # reproducibly, so the image is compared with a small tolerance
    @test size(img_test) == size(img_ref)
    frac_diff = sum(img_test .!= img_ref) / length(img_ref)
    @test frac_diff < 0.02

    rm(testpng; force=true)

    # attribute tests: the points carry observed on x and predicted on y
    x, y, line, r2 = get_predict_observations_coords(observed, predicted; resp=1)

    plt = predictobsplot(x, y, line, r2)

    # the scatter of the points, found by its y matching the predicted values
    point_series = [s for s in plt.series_list if s[:seriestype] == :scatter && s[:y] == y]
    @test length(point_series) == 1
    @test point_series[1][:x] == x

    # the reference line is a two-point path running corner to corner of the diagonal
    lo, hi = line
    refline = [s for s in plt.series_list
                     if s[:seriestype] == :path && s[:x] == [lo, hi] && s[:y] == [lo, hi]]
    @test length(refline) == 1

    # with the reference line off, no such path
    plt_noref = predictobsplot(x, y, line, r2; refline=false)
    @test isempty([s for s in plt_noref.series_list
                         if s[:seriestype] == :path && s[:x] == [lo, hi] && s[:y] == [lo, hi]])

end