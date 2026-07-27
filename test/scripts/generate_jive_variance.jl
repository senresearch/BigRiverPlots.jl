# generate_jive_variance.jl — build the JIVE variance fixture and its reference image.
#
# Run once, by hand, to regenerate the fixture and the reference:
#   julia --project=. test/scripts/generate_jive_variance.jl
#
# It fits a JIVE model on three small, seeded, row-centered and Frobenius-normalized data
# blocks (the scaling jive uses internally), then saves the raw scaled blocks together
# with the fitted joint (m.J) and individual (m.A) structure as test/data/jive_variance_*.he,
# and renders the variance plot with the default attributes as test/ref/jive_variance_ref.png.

using BigRiverEssence
using WolfRiverPlots
using Plots
using Helium
using StableRNGs
using Statistics
using LinearAlgebra

rng = StableRNG(20240729)

#############
# The data  #
#############

# a joint signal shared by every block plus a signal of each block's own, so each bar
# carries a real joint part, a real individual part, and a small residual. Blocks hold the
# variables in ROWS and the observations in COLUMNS, the layout jive expects.
n = 90
joint_signal = randn(rng, 3, n)

Xs = [
    randn(rng, 10, 3) * joint_signal .+ 0.6 .* randn(rng, 10, n) .+ 0.3 .* randn(rng, 10, n),
    randn(rng, 8,  3) * joint_signal .+ 0.6 .* randn(rng, 8,  n) .+ 0.3 .* randn(rng, 8,  n),
    randn(rng, 12, 3) * joint_signal .+ 0.6 .* randn(rng, 12, n) .+ 0.3 .* randn(rng, 12, n),
]

########################
# Scale as jive does   #
########################

# jive row-centers each block, then Frobenius-normalizes so no block dominates. The
# fractions are measured against these scaled blocks, so the fixture stores the scaled
# blocks, not the raw ones, to match what the fit saw.
nel = [size(X, 1) * size(X, 2) for X in Xs]
sum_n = sum(nel)
Dat = [ let Xi = X .- mean(X, dims = 2); Xi ./ (norm(Xi) * sqrt(sum_n)); end for X in Xs ]

#############
# The fit   #
#############

m = jive(Dat)

# m.J is the vector of per-block joint structure, m.A the per-block individual structure
joint = m.J
individual = m.A

######################
# Save the fixture   #
######################

datadir = joinpath(@__DIR__, "..", "data")
mkpath(datadir)

# Helium writes one matrix per file, so each block, joint, and individual matrix is saved
# under an indexed name, and the count is recorded so the test knows how many to read back
for i in 1:length(Dat)
    Helium.writehe(Dat[i],        joinpath(datadir, "jive_variance_block_$(i).he"))
    Helium.writehe(joint[i],      joinpath(datadir, "jive_variance_joint_$(i).he"))
    Helium.writehe(individual[i], joinpath(datadir, "jive_variance_individual_$(i).he"))
end
Helium.writehe(reshape([Float64(length(Dat))], 1, 1),
               joinpath(datadir, "jive_variance_nblocks.he"))

######################
# Save the reference #
######################

refdir = joinpath(@__DIR__, "..", "ref")
mkpath(refdir)

# the default render, three stacked bars, the one the image test compares against
plot_jive_variance(Dat, joint, individual)
savefig(joinpath(refdir, "jive_variance_ref.png"))

println("generate_jive_variance: wrote data/jive_variance_*.he, ref/jive_variance_ref.png")