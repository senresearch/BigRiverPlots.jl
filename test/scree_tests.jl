# scree_tests.jl — image and attribute tests for the scree plot.
#
# These read the fixture that generate_scree.jl left behind, so no model is fitted here.
# The image test renders the default plot and compares it to the stored reference; the
# attribute tests build the plot object and check the bars and the line carry the values.

@testset "scree plot" begin

	#####################
	# Load the fixture  #
	#####################

	datadir = joinpath(@__DIR__, "data")
	refdir = joinpath(@__DIR__, "ref")

	values = vec(Helium.readhe(joinpath(datadir, "scree_input.he")))

	#####################
	# The image test    #
	#####################

	testpng = joinpath(@__DIR__, "scree_test.png")
	plot_scree(values)
	savefig(testpng)

	img_ref = FileIO.load(joinpath(refdir, "scree_ref.png"))
	img_test = FileIO.load(testpng)

	@test img_test == img_ref

	rm(testpng; force = true)

	#########################
	# The attribute tests   #
	#########################

	# get_scree_coords is what the wrapper calls, so the same call gives the x and y the
	# recipe draws
	x, y, names = get_scree_coords(values)

	plt = screeplot(x, y, names)

	# the recipe draws the bars and, by default, a line riding their tops, both on the same
	# x and y. The two series carrying y are those, found by value rather than by type
	with_y = [s for s in plt.series_list if s[:y] == y]

	# the bars and the line, so two series hold the values
	@test length(with_y) == 2

	# both carry the same x
	for s in with_y
		@test s[:x] == x
	end

	# with the line turned off, only the bars carry the values
	plt_noline = screeplot(x, y, names; showline = false)
	with_y_noline = [s for s in plt_noline.series_list if s[:y] == y]
	@test length(with_y_noline) == 1

end
