# sparsity_tests.jl — image and attribute tests for the sparsity plot.

@testset "sparsity plot" begin

	datadir = joinpath(@__DIR__, "data")
	refdir = joinpath(@__DIR__, "ref")

	loadings = Helium.readhe(joinpath(datadir, "sparsity_input.he"))

	# image test
	testpng = joinpath(@__DIR__, "sparsity_test.png")
	plot_sparsity(loadings)
	savefig(testpng)

	img_ref = FileIO.load(joinpath(refdir, "sparsity_ref.png"))
	img_test = FileIO.load(testpng)

	# the count labels ride an invisible scatter that GR does not place bit-for-bit
	# reproducibly, so the image is compared with a small tolerance
	@test size(img_test) == size(img_ref)
	frac_diff = sum(img_test .!= img_ref) / length(img_ref)
	@test frac_diff < 0.02

	rm(testpng; force = true)

	# attribute tests: the bars carry the counts, found by value not by type
	x, y, names = get_sparsity_coords(loadings)

	plt = sparsityplot(x, y, names)

	with_y = [s for s in plt.series_list if s[:y] == y]
	@test length(with_y) >= 1
	@test any(s -> s[:x] == x, with_y)

end
