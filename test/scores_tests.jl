# scores_tests.jl — image and attribute tests for the scores plot.
#
# These read the fixture that generate_scores.jl left behind, so no model is fitted
# here. The image test renders the default plot and compares it to the stored reference;
# the attribute tests build the plot object and check the data reached the right series.

@testset "scores plot" begin

	#####################
	# Load the fixture  #
	#####################

	datadir = joinpath(@__DIR__, "data")
	refdir = joinpath(@__DIR__, "ref")

	scores = Helium.readhe(joinpath(datadir, "scores_input.he"))

	# the group was stored as an integer per level, so it is read back and turned into
	# labels again, the same labels generate_scores.jl used
	group_codes = Int.(vec(Helium.readhe(joinpath(datadir, "scores_group.he"))))
	levels = ["a", "b", "c"]
	group = [levels[c] for c in group_codes]

	#####################
	# The image test    #
	#####################

	# render the default plot, exactly as the reference was rendered, to a temporary file
	testpng = joinpath(@__DIR__, "scores_test.png")
	plot_scores(scores; group = group)
	savefig(testpng)

	img_ref = FileIO.load(joinpath(refdir, "scores_ref.png"))
	img_test = FileIO.load(testpng)

	@test img_test == img_ref

	# clear the temporary file whether or not the test passed
	rm(testpng; force = true)

	#########################
	# The attribute tests   #
	#########################

	# get_scores_coords is what the wrapper calls, so the same call gives the x and y the
	# recipe should have placed on its scatter series
	x, y = get_scores_coords(scores; comps = (1, 2))

	# build the plot object and find the scatter series, since the recipe draws the origin
	# vline and hline first and the scatter, split one per group, after them
	plt = scoresplot(x, y, group)

	scatter_series = [s for s in plt.series_list if s[:seriestype] == :scatter]

	# the group has three levels, so there should be three scatter series
	@test length(scatter_series) == 3

	# the union of the three series, over the observations, is the whole of x and y, so
	# gathering their points back up should recover the inputs up to the grouping order
	xs = reduce(vcat, [s[:x] for s in scatter_series])
	ys = reduce(vcat, [s[:y] for s in scatter_series])

	@test sort(xs) == sort(x)
	@test sort(ys) == sort(y)

end
