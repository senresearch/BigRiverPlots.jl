# vip_tests.jl — image and attribute tests for the VIP plot.
#
# These read the fixture that generate_vip.jl left behind, so no model is fitted here.
# The image test renders the default plot and compares it to the stored reference; the
# attribute tests build the plot object and check the sorted bars and the threshold line.

@testset "vip plot" begin

	#####################
	# Load the fixture  #
	#####################

	datadir = joinpath(@__DIR__, "data")
	refdir = joinpath(@__DIR__, "ref")

	V = Helium.readhe(joinpath(datadir, "vip_input.he"))

	#####################
	# The image test    #
	#####################

	testpng = joinpath(@__DIR__, "vip_test.png")
	plot_vip(V)
	savefig(testpng)

	img_ref = FileIO.load(joinpath(refdir, "vip_ref.png"))
	img_test = FileIO.load(testpng)

	@test img_test == img_ref

	rm(testpng; force = true)

	#########################
	# The attribute tests   #
	#########################

	# get_vip_coords is what the wrapper calls, so the same call gives the sorted values
	# the recipe draws. The recipe reverses them for the horizontal bars, so the bar y is
	# the reverse of the helper's y
	x, y, names = get_vip_coords(V)

	plt = vipplot(x, y, names)

	# the bars carry the reversed values, found by value rather than by type
	with_rev = [s for s in plt.series_list if s[:y] == reverse(y)]
	@test length(with_rev) == 1

	# the values are sorted from the largest, so the helper's y is non-increasing
	@test issorted(y; rev = true)

	# the threshold line is a vertical line at one, drawn by default. A vline is a series
	# recipe, so after the pipeline its seriestype no longer reads as :vline; instead it is
	# found as the series whose x is entirely the threshold value of one
	threshold_series = [s for s in plt.series_list
							  if !isempty(s[:x]) && all(==(1.0), s[:x])]
	@test length(threshold_series) == 1

	# with the threshold line turned off, no series sits at the constant x of one
	plt_nothr = vipplot(x, y, names; thresholdline = false)
	@test isempty([s for s in plt_nothr.series_list
						 if !isempty(s[:x]) && all(==(1.0), s[:x])])

end
