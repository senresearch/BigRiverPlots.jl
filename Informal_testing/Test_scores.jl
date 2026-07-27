# test_scores.jl — informal check of the scores plot, for every model of BigRiverEssence.
#
# Best run from the REPL so the windows stay up:
#   julia> include("test_scores.jl")
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

println("data: X $(size(X)), Y $(size(Y)), Xt $(size(Xt)), Yt $(size(Yt))")
println("      y $(length(y)) labels in $(length(unique(y))) classes\n")

# ===========================================================================
# ONE SCORES PLOT PER MODEL
# ===========================================================================

# --- pca -------------------------------------------------------------------
# the labels are plot attributes, so the caller names the components
m_pca = pca(X; k = 4)
println("pca      : propOFvar = ", round.(m_pca.propOFvar, digits = 3))
display(plot_scores(pca_transform(m_pca, X);
                    group = y,
                    xlabel = "PC 1 ($(round(100 * m_pca.propOFvar[1], digits = 1))%)",
                    ylabel = "PC 2 ($(round(100 * m_pca.propOFvar[2], digits = 1))%)",
                    title = "PCA"))

# --- spc -------------------------------------------------------------------
m_spc = spc(X; k = 4, c = sqrt(p) / 2)
println("spc      : variances = ", round.(m_spc.variances, digits = 2))
display(plot_scores(((X .- m_spc.mean') ./ m_spc.scale') * m_spc.loadings;
                    group = y,
                    xlabel = "SPC 1 (var=$(round(m_spc.variances[1], digits = 2)))",
                    ylabel = "SPC 2 (var=$(round(m_spc.variances[2], digits = 2)))",
                    title = "sparse PCA"))

# --- spc_orth --------------------------------------------------------------
m_spco = spc_orth(X; k = 4, c = sqrt(p) / 2)
println("spc_orth : variances = ", round.(m_spco.variances, digits = 2))
display(plot_scores(((X .- m_spco.mean') ./ m_spco.scale') * m_spco.loadings;
                    group = y,
                    xlabel = "SPC 1", ylabel = "SPC 2",
                    title = "sparse PCA, orthogonal scores"))

# --- pmd -------------------------------------------------------------------
m_pmd = pmd(X; K = 4, sumabs = 0.4)
println("pmd      : d = ", round.(m_pmd.d, digits = 2),
        "  nonzeros in u = ", [count(!iszero, m_pmd.u[:, k]) for k in 1:m_pmd.K])
display(plot_scores(m_pmd.u;
                    group = y,
                    xlabel = "Comp 1 (d=$(round(m_pmd.d[1], digits = 2)))",
                    ylabel = "Comp 2 (d=$(round(m_pmd.d[2], digits = 2)))",
                    title = "PMD"))

# --- plskern ---------------------------------------------------------------
# a Plskern stores no per component strength, so the axes carry the bare names
m_pls = plskern(X, Y; nlv = 3)
println("plskern  : T = ", size(m_pls.T), " (no per component strength stored)")
display(plot_scores(m_pls.T;
                    group = y,
                    xlabel = "LV 1", ylabel = "LV 2",
                    title = "kernel PLS"))

# --- plsda -----------------------------------------------------------------
m_plsda = plsda(X, y, 3)
println("plsda    : classes = ", m_plsda.classes, "  (unique levels, NOT per observation)")
display(plot_scores(m_plsda.variates_X;
                    group = y,
                    xlabel = "X-variate 1", ylabel = "X-variate 2",
                    title = "PLS-DA"))

# --- splsda ----------------------------------------------------------------
m_splsda = splsda(X, y, 3, [5, 5, 5])
println("splsda   : keepX = ", m_splsda.keepX)
display(plot_scores(m_splsda.variates_X;
                    group = y,
                    xlabel = "X-variate 1 ($(m_splsda.keepX[1]) vars)",
                    ylabel = "X-variate 2 ($(m_splsda.keepX[2]) vars)",
                    title = "sparse PLS-DA"))

# --- cca -------------------------------------------------------------------
# cca_transform returns the variates with components in ROWS, so they are transposed
m_cca = cca(Xt, Yt; outdim = 3)
println("cca      : corrs = ", round.(m_cca.corrs, digits = 3))
display(plot_scores(permutedims(cca_transform(m_cca, Xt, :x));
                    group = y,
                    xlabel = "X-variate 1 (r=$(round(m_cca.corrs[1], digits = 2)))",
                    ylabel = "X-variate 2 (r=$(round(m_cca.corrs[2], digits = 2)))",
                    title = "CCA, X side"))
display(plot_scores(permutedims(cca_transform(m_cca, Yt, :y));
                    group = y,
                    xlabel = "Y-variate 1 (r=$(round(m_cca.corrs[1], digits = 2)))",
                    ylabel = "Y-variate 2 (r=$(round(m_cca.corrs[2], digits = 2)))",
                    title = "CCA, Y side"))

# --- scca ------------------------------------------------------------------
# an Scca stores no variates, so they are computed from the data it was fitted on
m_scca = scca(Xt, Yt; K = 3, penaltyx = 0.5, penaltyz = 0.5)
println("scca     : cors = ", round.(m_scca.cors, digits = 3),
        "  nonzeros in u = ", [count(!iszero, m_scca.u[:, k]) for k in 1:m_scca.K])
display(plot_scores(permutedims(Xt) * m_scca.u;
                    group = y,
                    xlabel = "X-variate 1 (r=$(round(m_scca.cors[1], digits = 2)))",
                    ylabel = "X-variate 2 (r=$(round(m_scca.cors[2], digits = 2)))",
                    title = "sparse CCA, X side"))

# --- jive ------------------------------------------------------------------
m_jive = jive(Xs; r = 2, ri = [1, 1])
println("jive     : r = ", m_jive.r, "  ri = ", m_jive.ri, "  S = ", size(m_jive.S))
display(plot_scores(permutedims(m_jive.S);
                    group = y,
                    xlabel = "Joint 1", ylabel = "Joint 2",
                    title = "JIVE, joint scores"))

# ===========================================================================
# THE KNOBS
# ===========================================================================

# no grouping at all, so one series and no legend
display(plot_scores(pca_transform(m_pca, X); title = "no group"))

# a different pair of components
display(plot_scores(pca_transform(m_pca, X); group = y, comps = (1, 3),
                    xlabel = "PC 1", ylabel = "PC 3",
                    title = "comps = (1, 3)"))

# no labels at all, so the recipe defaults stand
display(plot_scores(pca_transform(m_pca, X); group = y, title = "recipe default labels"))

# the legend text comes from the group vector, so relabelling it relabels the legend
display(plot_scores(pca_transform(m_pca, X);
                    group = replace(y, "a" => "x", "b" => "y", "c" => "z"),
                    title = "legend as x, y, z"))

# the recipe keyword
display(plot_scores(pca_transform(m_pca, X); group = y, origincolor = :red,
                    title = "origincolor = :red"))

# the `-->` defaults should yield to whatever the caller passes
display(plot_scores(pca_transform(m_pca, X); group = y,
                    title = "overrides: marker 12, no legend",
                    marker = 12, legend = false, size = (500, 400)))

# ===========================================================================
# THE GUARDS
# ===========================================================================

println("\n--- guards ---")

# comps out of range
try
    plot_scores(pca_transform(m_pca, X); comps = (1, 9))
    println("!! expected an error for comps = (1, 9), none thrown")
catch e
    println("comps out of range     : ", e)
end

# a group vector of the wrong length
try
    plot_scores(pca_transform(m_pca, X); group = ["a", "b"])
    println("!! expected an error for a short group vector, none thrown")
catch e
    println("short group vector     : ", e)
end

println("\ndone — every model above should have drawn three colored clusters.")