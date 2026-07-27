# generate_pairs.jl — build the pairs fixture and its reference image.
#
# Run once, by hand, to regenerate the fixture and the reference:
#   julia --project=. test/scripts/generate_pairs.jl
#
# It fits a PCA on a small, seeded data set, extracts the scores matrix, saves it and a
# group vector as test/data/pairs_input.he, then renders the pairs plot with the default
# attributes and saves it as test/ref/pairs_ref.png.

using BigRiverEssence
using WolfRiverPlots
using Plots
using Helium
using StableRNGs

rng = StableRNG(20240723)

#############
# The data  #
#############

n = 60
p = 12
latent = randn(rng, n, 3)
X = latent * randn(rng, 3, p) .+ 0.3 .* randn(rng, n, p)

group = repeat(["a", "b", "c"], inner = n ÷ 3)

#############
# The fit   #
#############

m = pca(X; k = 4)
scores = pca_transform(m, X)

######################
# Save the fixture   #
######################

datadir = joinpath(@__DIR__, "..", "data")
mkpath(datadir)

Helium.writehe(scores, joinpath(datadir, "pairs_input.he"))

levels = unique(group)
lookup = Dict(l => i for (i, l) in enumerate(levels))
group_codes = reshape(Float64[lookup[g] for g in group], :, 1)
Helium.writehe(group_codes, joinpath(datadir, "pairs_group.he"))

######################
# Save the reference #
######################

refdir = joinpath(@__DIR__, "..", "ref")
mkpath(refdir)

# the default render, the first three components crossed, the one the image test compares
plot_pairs(scores; comps = [1, 2, 3], group = group)
savefig(joinpath(refdir, "pairs_ref.png"))

println("generate_pairs: wrote data/pairs_input.he, data/pairs_group.he, ref/pairs_ref.png")