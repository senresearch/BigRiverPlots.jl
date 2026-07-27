# generate_scores.jl — build the scores fixture and its reference image.
#
# Run once, by hand, to regenerate the fixture and the reference. The tests never
# run this; they read the .he it leaves behind:
#   julia --project=. test/scripts/generate_scores.jl
#
# It fits a PCA on a small, seeded data set, extracts the scores matrix, and saves
# that matrix and a group vector as test/data/scores_input.he, then renders the
# scores plot with the default attributes and saves it as test/ref/scores_ref.png.

using BigRiverEssence
using WolfRiverPlots
using Plots
using Helium
using StableRNGs

# a fixed stream, stable across Julia versions, so the fixture never drifts
rng = StableRNG(20240720)

#############
# The data  #
#############

# three latent signals drive the features, so the PCA has real structure to find
n = 60
p = 12
latent = randn(rng, n, 3)
X = latent * randn(rng, 3, p) .+ 0.3 .* randn(rng, n, p)

# a class label per observation, in three balanced groups
group = repeat(["a", "b", "c"], inner = n ÷ 3)

#############
# The fit   #
#############

m = pca(X; k = 4)

# the scores matrix is the input the scores plot takes, so it is what we store
scores = pca_transform(m, X)

######################
# Save the fixture   #
######################

datadir = joinpath(@__DIR__, "..", "data")
mkpath(datadir)

# Helium writes a matrix, so the scores go in one file and the group, encoded as an
# integer per level, in another. The test reads both back
Helium.writehe(scores, joinpath(datadir, "scores_input.he"))

levels = unique(group)
lookup = Dict(l => i for (i, l) in enumerate(levels))
group_codes = reshape(Float64[lookup[g] for g in group], :, 1)
Helium.writehe(group_codes, joinpath(datadir, "scores_group.he"))

######################
# Save the reference #
######################

refdir = joinpath(@__DIR__, "..", "ref")
mkpath(refdir)

# the default render, the one the image test compares against
plot_scores(scores; group = group)
savefig(joinpath(refdir, "scores_ref.png"))

println("generate_scores: wrote data/scores_input.he, data/scores_group.he, ref/scores_ref.png")