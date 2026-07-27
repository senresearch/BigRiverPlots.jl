# jive_variance_tests.jl — image and attribute tests for the JIVE variance plot.

@testset "jive variance plot" begin

	datadir = joinpath(@__DIR__, "data")
	refdir = joinpath(@__DIR__, "ref")

	# how many blocks the generator saved, read back as an Int
	k = Int(Helium.readhe(joinpath(datadir, "jive_variance_nblocks.he"))[1])

	blocks     = [Helium.readhe(joinpath(datadir, "jive_variance_block_$(i).he")) for i in 1:k]
	joint      = [Helium.readhe(joinpath(datadir, "jive_variance_joint_$(i).he")) for i in 1:k]
	individual = [Helium.readhe(joinpath(datadir, "jive_variance_individual_$(i).he")) for i in 1:k]

	#############
	# Image     #
	#############

	testpng = joinpath(@__DIR__, "jive_variance_test.png")
	plot_jive_variance(blocks, joint, individual)
	savefig(testpng)

	img_ref = FileIO.load(joinpath(refdir, "jive_variance_ref.png"))
	img_test = FileIO.load(testpng)

	# a clean stacked-bar plot, no annotations, so the render is reproducible and the
	# image is compared exactly, as with scree and vip
	@test img_test == img_ref

	rm(testpng; force = true)

	#####################
	# Attributes        #
	#####################

	# recompute the fractions so the segments can be matched by what they represent
	varJ, varI, varR, _ = get_jive_variance_coords(blocks, joint, individual)

	plt = plot_jive_variance(blocks, joint, individual)
	series = plt.series_list

	# each :bar @series is expanded by the pipeline into a filled polygon plus a separate
	# outline series, so k segments produce 2k series. Keep only the filled shapes, then
	# key them by label — this guarantees the height checks below read the fill, not the
	# outline.
	shapes = filter(s -> s[:seriestype] in (:shape, :bar), series)
	bylabel = Dict(s[:label] => s for s in shapes)

	@test length(series) >= 3
	@test haskey(bylabel, "Residual")
	@test haskey(bylabel, "Individual")
	@test haskey(bylabel, "Joint")

	# a segment's y is the vertex list of its polygons, not the running total, so match on
	# geometry: the top vertex of each segment reaches its running total across blocks.
	# residual runs 0→varR, individual runs varR→varR+varI, joint runs varR+varI→the total.
	segtop(s) = maximum(filter(!isnan, s[:y]))
	@test segtop(bylabel["Residual"]) ≈ maximum(varR)
	@test segtop(bylabel["Individual"]) ≈ maximum(varR .+ varI)
	@test segtop(bylabel["Joint"]) ≈ maximum(varR .+ varI .+ varJ)

	# joint is the topmost segment and never exceeds one, since the three fractions sum to
	# at most one per block
	@test segtop(bylabel["Joint"]) <= 1.0 + 1e-8

	# the three labelled segments are drawn as filled shapes; the pipeline may add outline
	# series alongside them, which we don't constrain
	@test all(s -> s[:seriestype] in (:shape, :bar),
		(bylabel["Residual"], bylabel["Individual"], bylabel["Joint"]))
end
