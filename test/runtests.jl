# runtests.jl — runs every test: the helper unit tests, the utils tests, and the plot
# image and attribute tests.
#
#   julia --project=. -e 'using Pkg; Pkg.test()'
#
# The fixtures under test/data and the reference images under test/ref are NOT built
# here. They are built once, by hand, with test/scripts/generate_all.jl, and this runner
# only reads them. Regenerating is a deliberate act, since it overwrites the very files
# the plot tests compare against.

using Test

using BigRiverEssence
using BigRiverPlots
using Plots
using Helium
using FileIO
using StableRNGs
using Random, Distributions
ENV["GKSwstype"] = "nul"




@testset "BigRiverPlots.jl" begin
	include("recipes_tests.jl")

	###########
	# helpers #
	###########

	include("utils_tests.jl")
	include("scores_helpers_tests.jl")
	include("loadings_helpers_tests.jl")
	include("loadings_heatmap_helpers_tests.jl")
	include("pairs_helpers_tests.jl")
	include("biplot_helpers_tests.jl")
	include("scree_helpers_tests.jl")
	include("vip_helpers_tests.jl")
	include("sparsity_helpers_tests.jl")
	include("predict_observations_helpers_tests.jl")
	include("jive_variance_helpers_tests.jl")
	include("mosaic_helpers_tests.jl")

	#########
	# plots #
	#########

	include("scores_tests.jl")
	include("loadings_tests.jl")
	include("loadings_heatmap_tests.jl")
	include("pairs_tests.jl")
	include("biplot_tests.jl")
	include("scree_tests.jl")
	include("vip_tests.jl")
	include("sparsity_tests.jl")
	include("predict_observations_tests.jl")
	include("jive_variance_tests.jl")

end
