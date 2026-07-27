# loadings_tests.jl — image and attribute tests for the loadings plot.
#
# These read the fixture that generate_loadings.jl left behind, so no model is fitted
# here. The image test renders the default plot and compares it to the stored reference;
# the attribute tests build the plot object and check the data reached the right series.

@testset "loadings plot" begin

	#####################
	# Load the fixture  #
	#####################

	datadir = joinpath(@__DIR__, "data")
	refdir = joinpath(@__DIR__, "ref")

	loadings = Helium.readhe(joinpath(datadir, "loadings_input.he"))

	#####################
	# The image test    #
	#####################

	# render the default plot of the first component, exactly as the reference was rendered
	testpng = joinpath(@__DIR__, "loadings_test.png")
	plot_loadings(loadings; comp = 1)
	savefig(testpng)

	img_ref = FileIO.load(joinpath(refdir, "loadings_ref.png"))
	img_test = FileIO.load(testpng)

	@test img_test == img_ref

	rm(testpng; force = true)

	#########################
	# The attribute tests   #
	#########################

	# get_loadings_coords is what the wrapper calls, so the same call gives the x and y the
	# recipe should have placed on its bar series
	x, y, names = get_loadings_coords(loadings; comp = 1)

	# build the plot object. The recipe draws the origin hline first and the loadings bars
	# after it, so the loadings are the series whose y matches, found by value rather than
	# by series type, since the backend may relabel a bar
	plt = loadingsplot(x, y, names)

	match = [s for s in plt.series_list if s[:y] == y]

	@test length(match) == 1
	@test match[1][:x] == x
	@test match[1][:y] == y

end# loadings_tests.jl — image and attribute tests for the loadings plot.
#
# These read the fixture that generate_loadings.jl left behind, so no model is fitted
# here. The image test renders the default plot and compares it to the stored reference;
# the attribute tests build the plot object and check the data reached the right series.

@testset "loadings plot" begin

	#####################
	# Load the fixture  #
	#####################

	datadir = joinpath(@__DIR__, "data")
	refdir = joinpath(@__DIR__, "ref")

	loadings = Helium.readhe(joinpath(datadir, "loadings_input.he"))

	#####################
	# The image test    #
	#####################

	# render the default plot of the first component, exactly as the reference was rendered
	testpng = joinpath(@__DIR__, "loadings_test.png")
	plot_loadings(loadings; comp = 1)
	savefig(testpng)

	img_ref = FileIO.load(joinpath(refdir, "loadings_ref.png"))
	img_test = FileIO.load(testpng)

	@test img_test == img_ref

	rm(testpng; force = true)

	#########################
	# The attribute tests   #
	#########################

	# get_loadings_coords is what the wrapper calls, so the same call gives the x and y the
	# recipe should have placed on its bar series
	x, y, names = get_loadings_coords(loadings; comp = 1)

	# build the plot object. The recipe draws the origin hline first and the loadings bars
	# after it, so the loadings are the series whose y matches, found by value rather than
	# by series type, since the backend may relabel a bar
	plt = loadingsplot(x, y, names)

	match = [s for s in plt.series_list if s[:y] == y]

	@test length(match) == 1
	@test match[1][:x] == x
	@test match[1][:y] == y

end
