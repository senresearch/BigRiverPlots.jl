# generate_sparsity.jl — build the sparsity fixture and its reference image.
#
# Run once, by hand:  julia --project=. test/scripts/generate_sparsity.jl

using BigRiverEssence
using WolfRiverPlots
using Plots
using Helium
using StableRNGs

rng = StableRNG(20240727)

n = 60
p = 20
latent = randn(rng, n, 3)
X = latent * randn(rng, 3, p) .+ 0.3 .* randn(rng, n, p)

# a sparse fit, so each component selects only some variables and the counts vary
m = spc(X; k = 4, c = sqrt(p) / 2)
loadings = m.loadings

datadir = joinpath(@__DIR__, "..", "data")
mkpath(datadir)
Helium.writehe(loadings, joinpath(datadir, "sparsity_input.he"))

refdir = joinpath(@__DIR__, "..", "ref")
mkpath(refdir)
plot_sparsity(loadings)
savefig(joinpath(refdir, "sparsity_ref.png"))

println("generate_sparsity: wrote data/sparsity_input.he, ref/sparsity_ref.png")