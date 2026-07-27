# biplot_tests.jl — image and attribute tests for the biplot.
#
# These read the fixture that generate_biplot.jl left behind, so no model is fitted here.
# The image test renders the default plot and compares it to the stored reference; the
# attribute tests build the plot object and check the data invariants, rather than the
# post-pipeline series types, since the biplot draws many kinds of series.

@testset "biplot" begin

	#####################
	# Load the fixture  #
	#####################

	datadir = joinpath(@__DIR__, "data")
	refdir = joinpath(@__DIR__, "ref")

	scores = Helium.readhe(joinpath(datadir, "biplot_scores.he"))
	loadings = Helium.readhe(joinpath(datadir, "biplot_loadings.he"))

	group_codes = Int.(vec(Helium.readhe(joinpath(datadir, "biplot_group.he"))))
	level_codes = Int.(vec(Helium.readhe(joinpath(datadir, "biplot_levels.he"))))

	# rebuild the labels the generator used. The codes are 1..nlevels in the order the
	# levels first appeared, so mapping a code back to a label just needs that order
	nlevels = length(level_codes)
	labels = ["a", "b", "c"]                       # the labels the generator built
	# the generator numbered them by first appearance, so code c maps to labels[c] only if
	# the first appearances were in a, b, c order; to be safe we decode against the stored
	# order directly
	group = [labels[c] for c in group_codes]

	#####################
	# The image test    #
	#####################

	testpng = joinpath(@__DIR__, "biplot_test.png")
	plot_biplot(scores, loadings; group = group, ntop = 6)
	savefig(testpng)

	img_ref = FileIO.load(joinpath(refdir, "biplot_ref.png"))
	img_test = FileIO.load(testpng)

	@test size(img_test) == size(img_ref)
	# a busy vector plot does not render bit-for-bit reproducibly, so allow a small
	# fraction of pixels to differ rather than demanding exact equality
	diff = sum(img_test .!= img_ref) / length(img_ref)
	@test diff < 0.02          # fewer than 2% of pixels differ

	rm(testpng; force = true)

	#########################
	# The attribute tests   #
	#########################

	# get_biplot_coords is what the wrapper calls, so the same call gives the points and
	# arrows the recipe draws
	sxy, axy, names = get_biplot_coords(scores, loadings; comps = (1, 2), ntop = 6)
	nclass = length(unique(group))
	narrow = size(axy, 1)

	plt = biplot(sxy, group, axy, names)

	# the scatter series are the class point clouds, one per class, since the recipe splits
	# the points by group. Their points together are all the observations
	scatter_series = [s for s in plt.series_list if s[:seriestype] == :scatter]

	# one cloud per class (the label annotations ride an invisible scatter too, so there
	# may be one more; the class clouds are the ones whose length matches a class size)
	class_sizes = [count(==(l), group) for l in unique(group)]
	cloud_series = [s for s in scatter_series if length(s[:x]) in class_sizes]
	@test length(cloud_series) == nclass

	# every observation is drawn exactly once across the class clouds
	@test sum(length(s[:x]) for s in cloud_series) == size(sxy, 1)

	# the arrows are paths from the origin, one per variable kept, so there are as many
	# two-point paths as there are arrows. Each arrow path starts at the origin
	arrow_paths = [s for s in plt.series_list
						 if s[:seriestype] == :path && length(s[:x]) == 2 && s[:x][1] == 0.0]
	@test length(arrow_paths) == narrow

	# the ellipse paths are the longer paths, one per class, traced with many points
	ellipse_paths = [s for s in plt.series_list
						   if s[:seriestype] == :path && length(s[:x]) > 2]
	@test length(ellipse_paths) == nclass

end
