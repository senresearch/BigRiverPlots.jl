# generate_vip.jl — build the VIP fixture and its reference image.
#
# Run once, by hand, to regenerate the fixture and the reference:
#   julia --project=. test/scripts/generate_vip.jl
#
# It fits a PLS-DA on a small, seeded data set, computes the VIP matrix, saves it as
# test/data/vip_input.he, then renders the VIP plot with the default attributes and saves
# it as test/ref/vip_ref.png.

using BigRiverEssence
using WolfRiverPlots
using Plots
using Helium
using StableRNGs

rng = StableRNG(20240726)

#############
# The data  #
#############

# the class is read off the first latent signal, so a few variables stand out above the
# VIP threshold. p is set larger so the sorted bars read as a curve, as on real data
n = 90
p = 40
latent = randn(rng, n, 3)
X = latent * randn(rng, 3, p) .+ 0.3 .* randn(rng, n, p)
y = [latent[i, 1] > 0.4 ? "a" : latent[i, 1] < -0.4 ? "c" : "b" for i in 1:n]

#############
# The fit   #
#############

m = plsda(X, y, 3)

# the VIP matrix is the input the VIP plot takes
V = vip(m)

######################
# Save the fixture   #
######################

datadir = joinpath(@__DIR__, "..", "data")
mkpath(datadir)

Helium.writehe(V, joinpath(datadir, "vip_input.he"))

######################
# Save the reference #
######################

refdir = joinpath(@__DIR__, "..", "ref")
mkpath(refdir)

# the default render, the overall VIP sorted, the one the image test compares against
plot_vip(V)
savefig(joinpath(refdir, "vip_ref.png"))

println("generate_vip: wrote data/vip_input.he, ref/vip_ref.png")