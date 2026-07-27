# generate_biplot.jl — build the biplot fixture and its reference image.
#
# Run once, by hand, to regenerate the fixture and the reference:
#   julia --project=. test/scripts/generate_biplot.jl
#
# It fits a PCA on a small, seeded data set, extracts the scores and loadings, saves them
# and a group vector as test/data/biplot_*.he, then renders the biplot with the default
# attributes and saves it as test/ref/biplot_ref.png.

using BigRiverEssence
using WolfRiverPlots
using Plots
using Helium
using StableRNGs

rng = StableRNG(20240724)

#############
# The data  #
#############

# the class is read off the first latent signal, so the three groups actually separate
# and their ellipses ring distinct clouds
n = 60
p = 12
latent = randn(rng, n, 3)
X = latent * randn(rng, 3, p) .+ 0.3 .* randn(rng, n, p)

group = [latent[i, 1] > 0.4 ? "a" : latent[i, 1] < -0.4 ? "c" : "b" for i in 1:n]

#############
# The fit   #
#############

m = pca(X; k = 4)
scores = pca_transform(m, X)
loadings = m.loadings

######################
# Save the fixture   #
######################

datadir = joinpath(@__DIR__, "..", "data")
mkpath(datadir)

Helium.writehe(scores, joinpath(datadir, "biplot_scores.he"))
Helium.writehe(loadings, joinpath(datadir, "biplot_loadings.he"))

levels = unique(group)
lookup = Dict(l => i for (i, l) in enumerate(levels))
group_codes = reshape(Float64[lookup[g] for g in group], :, 1)
Helium.writehe(group_codes, joinpath(datadir, "biplot_group.he"))

# the levels themselves, so the test decodes the codes back to the same labels in the
# same order, whatever they happened to be
levelcodes = reshape(Float64[lookup[l] for l in levels], :, 1)
Helium.writehe(levelcodes, joinpath(datadir, "biplot_levels.he"))

######################
# Save the reference #
######################

refdir = joinpath(@__DIR__, "..", "ref")
mkpath(refdir)

# the default render, with the top few arrows, the one the image test compares against
plot_biplot(scores, loadings; group = group, ntop = 6)
savefig(joinpath(refdir, "biplot_ref.png"))

println("generate_biplot: wrote data/biplot_scores.he, biplot_loadings.he, biplot_group.he, ref/biplot_ref.png")