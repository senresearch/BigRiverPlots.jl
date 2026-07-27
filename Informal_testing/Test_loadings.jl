# test_loadings.jl — informal check of the loadings plot, for every model of BigRiverEssence.
#
# Best run from the REPL so the windows stay up:
#   julia> include("test_loadings.jl")
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
y = repeat(["a", "b", "c"], inner = n ÷ 3)          # class labels, one per observation

# names for the variable axis, so the ticks read as something
vnames = ["gene$(i)" for i in 1:p]

# cca, scca and jive hold the variables in ROWS and the observations in COLUMNS,
# but their LOADINGS are already variables by components, so none of them transpose here
Xt = permutedims(latent * randn(3, 6) .+ 0.3 .* randn(n, 6))    # 6×90
Yt = permutedims(latent * randn(3, 5) .+ 0.3 .* randn(n, 5))    # 5×90

Xs = [permutedims(latent * randn(3, 10) .+ 0.3 .* randn(n, 10)),   # 10×90
      permutedims(latent * randn(3, 8)  .+ 0.3 .* randn(n, 8))]    #  8×90

println("data: X $(size(X)), Xt $(size(Xt)), Yt $(size(Yt))\n")

# ===========================================================================
# ONE LOADINGS PLOT PER MODEL
# ===========================================================================

# --- pca -------------------------------------------------------------------
# a dense model, so every variable is drawn as a bar
m_pca = pca(X; k = 4)
println("pca      : loadings ", size(m_pca.loadings), " (dense)")
display(plot_loadings(m_pca.loadings;
                      comp = 1, varnames = vnames,
                      ylabel = "Loading on PC 1 ($(round(100 * m_pca.propOFvar[1], digits = 1))%)",
                      title = "PCA"))

# --- spc -------------------------------------------------------------------
# a sparse model, so only the selected variables are drawn, as sticks
m_spc = spc(X; k = 4, c = sqrt(p) / 2)
println("spc      : nonzeros per loading = ",
        [count(!iszero, m_spc.loadings[:, j]) for j in 1:size(m_spc.loadings, 2)], " of $p")
display(plot_loadings(m_spc.loadings;
                      comp = 1, varnames = vnames, nonzero = true, loadingsstyle = :sticks,
                      ylabel = "Loading on SPC 1 (var=$(round(m_spc.variances[1], digits = 2)))",
                      title = "sparse PCA, selected variables only"))

# the same component with every variable drawn, to see what nonzero is hiding
display(plot_loadings(m_spc.loadings;
                      comp = 1, varnames = vnames, loadingsstyle = :sticks,
                      ylabel = "Loading on SPC 1",
                      title = "sparse PCA, all variables"))

# --- pmd -------------------------------------------------------------------
m_pmd = pmd(X; K = 4, sumabs = 0.4)
println("pmd      : nonzeros in v = ", [count(!iszero, m_pmd.v[:, k]) for k in 1:m_pmd.K], " of $p")
display(plot_loadings(m_pmd.v;
                      comp = 1, varnames = vnames, nonzero = true, loadingsstyle = :sticks,
                      ylabel = "Loading on Comp 1 (d=$(round(m_pmd.d[1], digits = 2)))",
                      title = "PMD"))

# --- plskern ---------------------------------------------------------------
m_pls = plskern(X, Y; nlv = 3)
println("plskern  : P ", size(m_pls.P))
display(plot_loadings(m_pls.P;
                      comp = 1, varnames = vnames,
                      ylabel = "Loading on LV 1",
                      title = "kernel PLS, X loadings"))

# --- plsda -----------------------------------------------------------------
m_plsda = plsda(X, y, 3)
println("plsda    : loadings_X ", size(m_plsda.loadings_X))
display(plot_loadings(m_plsda.loadings_X;
                      comp = 1, varnames = vnames,
                      ylabel = "Loading on X-variate 1",
                      title = "PLS-DA"))

# --- splsda ----------------------------------------------------------------
m_splsda = splsda(X, y, 3, [5, 5, 5])
println("splsda   : keepX = ", m_splsda.keepX,
        "  nonzeros = ", [count(!iszero, m_splsda.loadings_X[:, k]) for k in 1:3])
display(plot_loadings(m_splsda.loadings_X;
                      comp = 1, varnames = vnames, nonzero = true, loadingsstyle = :sticks,
                      ylabel = "Loading on X-variate 1 ($(m_splsda.keepX[1]) vars)",
                      title = "sparse PLS-DA"))

# --- cca -------------------------------------------------------------------
m_cca = cca(Xt, Yt; outdim = 3)
println("cca      : xproj ", size(m_cca.xproj), "  yproj ", size(m_cca.yproj))
display(plot_loadings(m_cca.xproj;
                      comp = 1,
                      ylabel = "Loading on X-variate 1 (r=$(round(m_cca.corrs[1], digits = 2)))",
                      title = "CCA, X directions"))
display(plot_loadings(m_cca.yproj;
                      comp = 1,
                      ylabel = "Loading on Y-variate 1 (r=$(round(m_cca.corrs[1], digits = 2)))",
                      title = "CCA, Y directions"))

# --- scca ------------------------------------------------------------------
m_scca = scca(Xt, Yt; K = 3, penaltyx = 0.5, penaltyz = 0.5)
println("scca     : nonzeros in u = ", [count(!iszero, m_scca.u[:, k]) for k in 1:m_scca.K],
        " of ", size(m_scca.u, 1))
display(plot_loadings(m_scca.u;
                      comp = 2, nonzero = false, loadingsstyle = :sticks,
                      ylabel = "Loading on X-variate 1 (r=$(round(m_scca.cors[1], digits = 2)))",
                      title = "sparse CCA, X side"))

# --- jive ------------------------------------------------------------------
m_jive = jive(Xs; r = 2, ri = [1, 1])
println("jive     : U[1] ", size(m_jive.U[1]), "  U[2] ", size(m_jive.U[2]))
display(plot_loadings(m_jive.U[1];
                      comp = 1,
                      ylabel = "Loading on Joint 1",
                      title = "JIVE, joint loadings of block 1"))

# ===========================================================================
# THE KNOBS
# ===========================================================================

# a different component
display(plot_loadings(m_pca.loadings; comp = 3, varnames = vnames,
                      ylabel = "Loading on PC 3", title = "comp = 3"))

# ntop keeps the largest contributors, in variable order
display(plot_loadings(m_pca.loadings; comp = 1, varnames = vnames, ntop = 5,
                      title = "ntop = 5"))

# no varnames, so the variables keep their index
display(plot_loadings(m_pca.loadings; comp = 1, title = "no varnames"))

# no labels at all, so the recipe defaults stand
display(plot_loadings(m_pca.loadings; comp = 1, varnames = vnames,
                      title = "recipe default labels"))

# sticks on a dense model, to compare the two styles
display(plot_loadings(m_pca.loadings; comp = 1, varnames = vnames, loadingsstyle = :sticks,
                      title = "loadingsstyle = :sticks"))

# the recipe keywords
display(plot_loadings(m_pca.loadings; comp = 1, varnames = vnames,
                      loadingscolor = "#d94801", origincolor = :red,
                      title = "recipe keywords"))

# the `-->` defaults should yield to whatever the caller passes
display(plot_loadings(m_pca.loadings; comp = 1, varnames = vnames,
                      title = "overrides: legend on, small", legend = true,
                      size = (500, 400), guidefontsize = 9))

# ===========================================================================
# THE GUARDS
# ===========================================================================

println("\n--- guards ---")

# comp out of range
try
    plot_loadings(m_pca.loadings; comp = 9)
    println("!! expected an error for comp = 9, none thrown")
catch e
    println("comp out of range      : ", e)
end

# a varnames vector of the wrong length
try
    plot_loadings(m_pca.loadings; varnames = ["a", "b"])
    println("!! expected an error for a short varnames vector, none thrown")
catch e
    println("short varnames vector  : ", e)
end

# nonzero on a component with nothing selected
try
    plot_loadings(zeros(p, 2); nonzero = true)
    println("!! expected an error for an all zero component, none thrown")
catch e
    println("all zero component     : ", e)
end

println("\ndone — the sparse models should show a handful of sticks, the dense ones a full bar chart.")