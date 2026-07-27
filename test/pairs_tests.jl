# pairs_tests.jl — image and attribute tests for the pairs plot.
#
# These read the fixture that generate_pairs.jl left behind, so no model is fitted here.
# The image test renders the default plot and compares it to the stored reference; the
# attribute tests build the plot object and check the grid was laid out as expected.

@testset "pairs plot" begin

	#####################
	# Load the fixture  #
	#####################

	datadir = joinpath(@__DIR__, "data")
	refdir = joinpath(@__DIR__, "ref")

	scores = Helium.readhe(joinpath(datadir, "pairs_input.he"))

	group_codes = Int.(vec(Helium.readhe(joinpath(datadir, "pairs_group.he"))))
	levels = ["a", "b", "c"]
	group = [levels[c] for c in group_codes]

	#####################
	# The image test    #
	#####################

	testpng = joinpath(@__DIR__, "pairs_test.png")
	plot_pairs(scores; comps = [1, 2, 3], group = group)
	savefig(testpng)

	img_ref = FileIO.load(joinpath(refdir, "pairs_ref.png"))
	img_test = FileIO.load(testpng)

	@test img_test == img_ref

	rm(testpng; force = true)

	#########################
	# The attribute tests   #
	#########################

	# get_pairs_coords is what the wrapper calls, so the same call gives the matrix the
	# recipe lays into the grid
	z, names = get_pairs_coords(scores; comps = [1, 2, 3])
	k = size(z, 2)
	nlevels = length(unique(group))

	plt = pairsplot(z, group, names)

	# a k by k grid is k^2 cells, so there are k^2 subplots
	@test length(plt.subplots) == k * k

	# map each series to the index of the subplot it lands in
	function subplot_index(s)
		findfirst(==(s[:subplot]), plt.subplots)
	end

	diag_idx = [(r - 1) * k + r for r in 1:k]
	offdiag_idx = [(r - 1) * k + c for r in 1:k for c in 1:k if r != c]

	# count the series in each subplot
	counts = Dict{Int, Int}()
	for s in plt.series_list
		idx = subplot_index(s)
		counts[idx] = get(counts, idx, 0) + 1
	end

	# each off diagonal cell holds one scatter series per level. This is the assertion
	# that matters: the grouping split the points correctly, cell by cell
	for o in offdiag_idx
		@test get(counts, o, 0) == nlevels
	end

	# every diagonal cell holds at least its distribution series, so none is empty
	for d in diag_idx
		@test get(counts, d, 0) >= 1
	end

	# the scatter points in the OFF DIAGONAL cells hold every observation once per off
	# diagonal cell, so no point was dropped or duplicated by the grouping. Scoped to the
	# off diagonal so a distribution drawn on the diagonal does not inflate the count
	offdiag_scatter = [s for s in plt.series_list
							 if s[:seriestype] == :scatter && subplot_index(s) in offdiag_idx]
	total_offdiag_points = sum(length(s[:x]) for s in offdiag_scatter)
	@test total_offdiag_points == length(offdiag_idx) * size(z, 1)

end
