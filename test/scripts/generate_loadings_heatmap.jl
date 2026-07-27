# generate_loadings_heatmap.jl — build the loadings heatmap fixture and its reference.
#
# Run once, by hand, to regenerate the fixture and the reference:
#   julia --project=. test/scripts/generate_loadings_heatmap.jl
#
# It fits a sparse PCA on a small, seeded data set, extracts the loadings matrix, saves
# it as test/data/loadings_heatmap_input.he, then renders the loadings heatmap with the
# default attributes and saves it as test/ref/loadings_heatmap_ref.png.

using BigRiverEssence
using WolfRiverPlots
using Plots
using Helium
using StableRNGs

rng = StableRNG(20240722)

#############
# The data  #
#############

n = 60
p = 12
latent = randn(rng, n, 3)
X = latent * randn(rng, 3, p) .+ 0.3 .* randn(rng, n, p)

#############
# The fit   #
#############

# a sparse fit, so the heatmap has zeros to show as the midtone
m = spc(X; k = 4, c = sqrt(p) / 2)
loadings = m.loadings

######################
# Save the fixture   #
######################

datadir = joinpath(@__DIR__, "..", "data")
mkpath(datadir)

Helium.writehe(loadings, joinpath(datadir, "loadings_heatmap_input.he"))

######################
# Save the reference #
######################

refdir = joinpath(@__DIR__, "..", "ref")
mkpath(refdir)

# the default render, every component, the one the image test compares against
plot_loadings_heatmap(loadings)
savefig(joinpath(refdir, "loadings_heatmap_ref.png"))

println("generate_loadings_heatmap: wrote data/loadings_heatmap_input.he, ref/loadings_heatmap_ref.png")