# mosaic_helpers_tests.jl — unit tests for get_mosaic_coords.
#
# Self-contained: the tables are small matrices written by hand here, so the test asserts
# the helper's geometry and probabilities directly, with no fixture, model, or image.

@testset "get_mosaic_coords" begin

    # a two by two table with clean totals, so the widths and heights are exact fractions.
    #
    #          A     B
    #   low    30    10
    #   high   10    50
    #
    # column totals 40 and 60, grand total 100
    counts = [30.0 10.0
              10.0 50.0]

    x, w, bottoms, heights, cts, condprobs, jointprobs,
    colmarginals, coltotalprob, rn, cn, yt =
        get_mosaic_coords(counts; xpad = 0.0, ypad = 0.0)

    ###################
    # Column widths   #
    ###################
    # the marginal P(x): column A is 40/100, column B is 60/100
    @test w ≈ [0.4, 0.6]
    @test coltotalprob ≈ [0.4, 0.6]
    @test colmarginals ≈ [40.0, 60.0]

    ###################
    # Conditionals    #
    ###################
    # within column A, low is 30/40 and high is 10/40; within B, 10/60 and 50/60
    @test condprobs[:, 1] ≈ [0.75, 0.25]
    @test condprobs[:, 2] ≈ [10/60, 50/60]
    # each column's conditional probabilities sum to one
    @test sum(condprobs[:, 1]) ≈ 1.0
    @test sum(condprobs[:, 2]) ≈ 1.0

    ###################
    # Joint probs     #
    ###################
    # each cell over the grand total, so the whole table sums to one
    @test jointprobs ≈ counts ./ 100
    @test sum(jointprobs) ≈ 1.0
    # the joint is the width times the conditional: area of a tile
    @test jointprobs[1, 1] ≈ w[1] * condprobs[1, 1]

    ###################
    # Placing         #
    ###################
    # with no padding the first column is centred at half its width, the second past it
    @test x[1] ≈ 0.2                       # 0.4 / 2
    @test x[2] ≈ 0.4 + 0.3                 # first width, then half the second
    # the bottoms of column A stack the running total from zero
    @test bottoms[2, 1] ≈ 0.0              # high, at the base (stacked in reverse)
    @test bottoms[1, 1] ≈ 0.25            # low, sitting on high's height

    ###################
    # Names           #
    ###################
    # no names given, so they fall back to the index
    @test rn == ["Row 1", "Row 2"]
    @test cn == ["Col 1", "Col 2"]

    # names pass through when given
    _, _, _, _, _, _, _, _, _, rn2, cn2, _ =
        get_mosaic_coords(counts; rownames = ["low", "high"], colnames = ["A", "B"])
    @test rn2 == ["low", "high"]
    @test cn2 == ["A", "B"]

    ###################
    # The guards      #
    ###################
    # a negative count
    @test_throws ErrorException get_mosaic_coords([1.0 -2.0; 3.0 4.0])
    # an all zero table
    @test_throws ErrorException get_mosaic_coords(zeros(2, 2))
    # a rownames vector of the wrong length
    @test_throws ErrorException get_mosaic_coords(counts; rownames = ["only one"])
    # a colnames vector of the wrong length
    @test_throws ErrorException get_mosaic_coords(counts; colnames = ["A", "B", "C"])
end