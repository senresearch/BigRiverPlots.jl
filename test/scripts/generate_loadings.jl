# generate_loadings.jl — build the loadings fixture and its reference image.
#
# Run once, by hand, to regenerate the fixture and the reference:
#   julia --project=. test/scripts/generate_loadings.jl
#
# It fits a sparse PCA on a small, seeded data set, extracts the loadings matrix, and
# saves it as test/data/loadings_input.he, then renders the loadings plot of the first
# component with the default attributes and saves it as test/ref/loadings_ref.png.

using BigRiverEssence
using WolfRiverPlots
using Plots
using Helium
using StableRNGs

# a fixed stream, stable across Julia versions, so the fixture never drifts
rng = StableRNG(20240721)

#############
# The data  #
#############

# three latent signals drive the features, so the sparse PCA selects a few of them
n = 60
p = 12
latent = randn(rng, n, 3)
X = latent * randn(rng, 3, p) .+ 0.3 .* randn(rng, n, p)

#############
# The fit   #
#############

# a sparse fit, so most loadings are exactly zero and the plot has a sparse column to show
m = spc(X; k = 4, c = sqrt(p) / 2)

# the loadings matrix is the input the loadings plot takes, so it is what we store
loadings = m.loadings

######################
# Save the fixture   #
######################

datadir = joinpath(@__DIR__, "..", "data")
mkpath(datadir)

Helium.writehe(loadings, joinpath(datadir, "loadings_input.he"))

######################
# Save the reference #
######################

refdir = joinpath(@__DIR__, "..", "ref")
mkpath(refdir)

# the default render of the first component, the one the image test compares against
plot_loadings(loadings; comp = 1)
savefig(joinpath(refdir, "loadings_ref.png"))

println("generate_loadings: wrote data/loadings_input.he, ref/loadings_ref.png")