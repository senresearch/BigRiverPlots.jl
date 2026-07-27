# test_pairs.jl — informal check of the pairs plot, for every model of BigRiverEssence.
#
# Best run from the REPL so the windows stay up:
#   julia> include("test_pairs.jl")
#
# (needs Plots, BigRiverEssence and WolfRiverPlots in the active environment)

using Plots
using BigRiverEssence
using WolfRiverPlots
using Random

Random.seed!(42)

# ===========================================================================
# DATA
# ===========================================================================

# three latent signals drive every block, so each model has real structure to find
n = 90
p = 20
latent = randn(n, 3)

# observations in ROWS, features in COLUMNS
X = latent * randn(3, p) .+ 0.3 .* randn(n, p)
Y = latent * randn(3, 4) .+ 0.3 .* randn(n, 4)      # multivariate response for plskern
y = repeat(["a", "b", "c"], inner = n ÷ 3)          # class labels, ONE PER OBSERVATION

# cca, scca and jive hold the variables in ROWS and the observations in COLUMNS
Xt = permutedims(latent * randn(3, 6) .+ 0.3 .* randn(n, 6))    # 6×90
Yt = permutedims(latent * randn(3, 5) .+ 0.3 .* randn(n, 5))    # 5×90

Xs = [permutedims(latent * randn(3, 10) .+ 0.3 .* randn(n, 10)),   # 10×90
      permutedims(latent * randn(3, 8)  .+ 0.3 .* randn(n, 8))]    #  8×90

println("data: X $(size(X)), Xt $(size(Xt)), Yt $(size(Yt))")
println("      y $(length(y)) labels in $(length(unique(y))) classes\n")

# ===========================================================================
# ONE PAIRS PLOT PER MODEL
# ===========================================================================

# --- pca -------------------------------------------------------------------
m_pca = pca(X; k = 8)
println("pca      : propOFvar = ", round.(m_pca.propOFvar, digits = 3))
display(plot_pairs(pca_transform(m_pca, X);
                   comps = [1, 2, 3,4,5,6,7,8], group = y,
                   compnames = ["PC $(j)" for j in 1:8],
                   plot_title = "PCA scores"))

# --- spc -------------------------------------------------------------------
m_spc = spc(X; k = 4, c = sqrt(p) / 2)
println("spc      : variances = ", round.(m_spc.variances, digits = 2))
display(plot_pairs(((X .- m_spc.mean') ./ m_spc.scale') * m_spc.loadings;
                   comps = [1, 2, 3], group = y,
                   compnames = ["SPC $(j)" for j in 1:4],
                   plot_title = "sparse PCA scores"))

# --- pmd -------------------------------------------------------------------
m_pmd = pmd(X; K = 4, sumabs = 0.4)
println("pmd      : d = ", round.(m_pmd.d, digits = 2))
display(plot_pairs(m_pmd.u;
                   comps = [1, 2, 3], group = y,
                   compnames = ["Comp $(k)" for k in 1:m_pmd.K],
                   plot_title = "PMD sample factors"))

# --- plskern ---------------------------------------------------------------
m_pls = plskern(X, Y; nlv = 3)
println("plskern  : T = ", size(m_pls.T))
display(plot_pairs(m_pls.T;
                   group = y,
                   compnames = ["LV $(j)" for j in 1:3],
                   plot_title = "kernel PLS scores"))

# --- plsda -----------------------------------------------------------------
m_plsda = plsda(X, y, 3)
println("plsda    : variates_X ", size(m_plsda.variates_X))
display(plot_pairs(m_plsda.variates_X;
                   group = y,
                   compnames = ["X-variate $(j)" for j in 1:3],
                   plot_title = "PLS-DA"))

# --- splsda ----------------------------------------------------------------
m_splsda = splsda(X, y, 3, [5, 5, 5])
println("splsda   : keepX = ", m_splsda.keepX)
display(plot_pairs(m_splsda.variates_X;
                   group = y,
                   compnames = ["X-variate $(j)" for j in 1:3],
                   plot_title = "sparse PLS-DA"))

# --- cca -------------------------------------------------------------------
# cca_transform returns the variates with components in ROWS, so they are transposed
m_cca = cca(Xt, Yt; outdim = 3)
println("cca      : corrs = ", round.(m_cca.corrs, digits = 3))
display(plot_pairs(permutedims(cca_transform(m_cca, Xt, :x));
                   group = y,
                   compnames = ["X-variate $(j)" for j in 1:3],
                   plot_title = "CCA, X side"))

# --- scca ------------------------------------------------------------------
# an Scca stores no variates, so they are computed from the data it was fitted on
m_scca = scca(Xt, Yt; K = 3, penaltyx = 0.5, penaltyz = 0.5)
println("scca     : cors = ", round.(m_scca.cors, digits = 3))
display(plot_pairs(permutedims(Xt) * m_scca.u;
                   group = y,
                   compnames = ["X-variate $(j)" for j in 1:m_scca.K],
                   plot_title = "sparse CCA, X side"))

# --- jive ------------------------------------------------------------------
# jive is fitted at rank 3 here, since a rank 2 joint gives only a 2x2 grid
m_jive = jive(Xs; r = 3, ri = [1, 1])
println("jive     : r = ", m_jive.r, "  ri = ", m_jive.ri, "  S = ", size(m_jive.S))
display(plot_pairs(permutedims(m_jive.S);
                   group = y,
                   compnames = ["Joint $(j)" for j in 1:m_jive.r],
                   plot_title = "JIVE, joint scores"))

# ===========================================================================
# THE KNOBS
# ===========================================================================

# no grouping at all, so one series per cell and no legend
display(plot_pairs(pca_transform(m_pca, X); comps = [1, 2, 3],
                   plot_title = "no group"))

# the smallest grid, two components
display(plot_pairs(pca_transform(m_pca, X); comps = [1, 2], group = y,
                   compnames = ["PC $(j)" for j in 1:4],
                   plot_title = "comps = [1, 2]"))

# every component of the model, a 4x4 grid
display(plot_pairs(pca_transform(m_pca, X); group = y,
                   compnames = ["PC $(j)" for j in 1:4],
                   plot_title = "every component"))

# a non contiguous subset
display(plot_pairs(pca_transform(m_pca, X); comps = [1, 3, 4], group = y,
                   compnames = ["PC $(j)" for j in 1:4],
                   plot_title = "comps = [1, 3, 4]"))

# no names, so the components keep their index
display(plot_pairs(pca_transform(m_pca, X); comps = [1, 2, 3], group = y,
                   plot_title = "no compnames"))

# the recipe keywords
display(plot_pairs(pca_transform(m_pca, X); comps = [1, 2, 3], group = y,
                   diagcolor = "#d94801", diagbins = 8,
                   plot_title = "diagcolor and diagbins"))

# the `-->` defaults should yield to whatever the caller passes
display(plot_pairs(pca_transform(m_pca, X); comps = [1, 2, 3], group = y,
                   plot_title = "overrides: bigger markers, small canvas",
                   markersize = 6, size = (500, 500)))

# a per cell title would repeat, so it is blanked and plot_title carries the grid
display(plot_pairs(pca_transform(m_pca, X); comps = [1, 2, 3], group = y,
                   title = "this should NOT appear nine times",
                   plot_title = "title is blanked, plot_title is not"))

# ===========================================================================
# THE GUARDS
# ===========================================================================

println("\n--- guards ---")

# a component out of range
try
    plot_pairs(pca_transform(m_pca, X); comps = [1, 9])
    println("!! expected an error for comps = [1, 9], none thrown")
catch e
    println("comp out of range      : ", e)
end

# a single component, which leaves nothing off the diagonal
try
    plot_pairs(pca_transform(m_pca, X); comps = [1])
    println("!! expected an error for a single component, none thrown")
catch e
    println("one component only     : ", e)
end

# a group vector of the wrong length
try
    plot_pairs(pca_transform(m_pca, X); comps = [1, 2], group = ["a", "b"])
    println("!! expected an error for a short group vector, none thrown")
catch e
    println("short group vector     : ", e)
end

# a compnames vector of the wrong length
try
    plot_pairs(pca_transform(m_pca, X); compnames = ["a", "b"])
    println("!! expected an error for a short compnames vector, none thrown")
catch e
    println("short compnames vector : ", e)
end

println("\ndone — each grid should carry one legend, one title, and a shared scale down every column.")