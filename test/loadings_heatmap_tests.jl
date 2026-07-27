# loadings_heatmap_tests.jl — image and attribute tests for the loadings heatmap.
#
# These read the fixture that generate_loadings_heatmap.jl left behind, so no model is
# fitted here. The image test renders the default plot and compares it to the stored
# reference; the attribute test builds the plot object and checks the matrix reached the
# heatmap series.

@testset "loadings heatmap plot" begin

	#####################
	# Load the fixture  #
	#####################

	datadir = joinpath(@__DIR__, "data")
	refdir = joinpath(@__DIR__, "ref")

	loadings = Helium.readhe(joinpath(datadir, "loadings_heatmap_input.he"))

	#####################
	# The image test    #
	#####################

	testpng = joinpath(@__DIR__, "loadings_heatmap_test.png")
	plot_loadings_heatmap(loadings)
	savefig(testpng)

	img_ref = FileIO.load(joinpath(refdir, "loadings_heatmap_ref.png"))
	img_test = FileIO.load(testpng)

	@test img_test == img_ref

	rm(testpng; force = true)

	#########################
	# The attribute tests   #
	#########################

	# get_loadings_heatmap_coords is what the wrapper calls, so the same call gives the
	# matrix the recipe should have placed on its heatmap series
	z, xnames, ynames = get_loadings_heatmap_coords(loadings)

	# find the series carrying the matrix by its z, rather than by series type, since the
	# backend may relabel a heatmap
	plt = loadingsheatmapplot(z, xnames, ynames)

	match = [s for s in plt.series_list if haskey(s.plotattributes, :z) && s[:z] !== nothing]

	@test length(match) == 1

	# the heatmap z is stored as a surface, so it is unwrapped before comparing
	got = match[1][:z]
	got = got isa AbstractMatrix ? got : got.surf
	@test Matrix(got) == z

end
