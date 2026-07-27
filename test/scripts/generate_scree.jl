# generate_scree.jl — build the scree fixture and its reference image.
#
# Run once, by hand, to regenerate the fixture and the reference:
#   julia --project=. test/scripts/generate_scree.jl
#
# It fits a PCA on a small, seeded data set, extracts the per-component variances, saves
# them as test/data/scree_input.he, then renders the scree plot with the default
# attributes and saves it as test/ref/scree_ref.png.

using BigRiverEssence
using WolfRiverPlots
using Plots
using Helium
using StableRNGs

rng = StableRNG(20240725)

#############
# The data  #
#############

# three latent signals drive the features, so the scree falls after the third bar
n = 60
p = 12
latent = randn(rng, n, 3)
X = latent * randn(rng, 3, p) .+ 0.3 .* randn(rng, n, p)

#############
# The fit   #
#############

m = pca(X; k = 8)

# the vector of per-component variances is the input the scree plot takes
values = m.variances

######################
# Save the fixture   #
######################

datadir = joinpath(@__DIR__, "..", "data")
mkpath(datadir)

# Helium writes a matrix, so the vector goes in as a single column and is read back with vec
Helium.writehe(reshape(values, :, 1), joinpath(datadir, "scree_input.he"))

######################
# Save the reference #
######################

refdir = joinpath(@__DIR__, "..", "ref")
mkpath(refdir)

# the default render, bars with the line riding their tops, the one the image test compares
plot_scree(values)
savefig(joinpath(refdir, "scree_ref.png"))

println("generate_scree: wrote data/scree_input.he, ref/scree_ref.png")