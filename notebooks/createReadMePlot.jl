# make_banner.jl — build the panel of example plots for the README banner.
#
# Run from the package root:
#   julia --project=docs make_banner.jl
#
# writes images/banner.svg

using BigRiverEssence
using WolfRiverPlots
using Plots
using StableRNGs
using Statistics
using LinearAlgebra

gr()

rng = StableRNG(20240801)

# ===========================================================================
# DATA — one shared simulation, three latent signals driving twenty variables
# ===========================================================================

n = 90    # observations
p = 20    # variables

latent = randn(rng, n, 3)
X = latent * randn(rng, 3, p) .+ 0.3 .* randn(rng, n, p)

y = [latent[i, 1] > 0.4 ? "a" : latent[i, 1] < -0.4 ? "c" : "b" for i in 1:n]
vnames = ["gene$(i)" for i in 1:p]

m = pca(X; k = 6)
S = pca_transform(m, X)

# ===========================================================================
# THE PANELS — four plots that look distinct at a glance
# ===========================================================================

# a biplot, the signature figure: points plus arrows
p1 = plot_biplot(S, m.loadings;
                 group = y, varnames = vnames, ntop = 5,
                 title = "biplot", legend = false,
                 xlabel = "", ylabel = "")

p2 = plot_loadings_heatmap(m.loadings;
                           compnames = ["PC$(j)" for j in 1:6],
                           title = "loadings", colorbar = false,
                           maxnames = 0,          # drop the crowded row numbers
                           ylims = (0.5, 20.5),
                           xlabel = "", ylabel = "")

p3 = plot_scree(m.propOFvar;
                compnames = ["PC$(j)" for j in 1:6],
                title = "scree", legend = false,
                xlabel = "", ylabel = "")

counts = Float64[30 10 5 2; 12 40 8 3; 4 6 25 20]
p4 = plot_mosaic(counts;
                 rownames = ["low","mid","high"], colnames = ["A","B","C","D"],
                 mode = :total, title = "mosaic", legend = false,
                 xlabel = "", ylabel = "")



# ===========================================================================
# THE PANEL — lay them out in a two by two grid
# ===========================================================================

banner = plot(p1, p2, p3, p4;
              layout = grid(1, 4),
              size = (1800, 460),
              margin = 6Plots.mm,
              titlefontsize = 12)             

mkpath("images")
savefig(banner, "images/banner.svg")

println("wrote images/banner.svg")