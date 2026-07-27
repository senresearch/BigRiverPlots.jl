# test_loadings_heatmap.jl — informal check of the loadings heatmap, for every model
# of BigRiverEssence.
#
# Best run from the REPL so the windows stay up:
#   julia> include("test_loadings_heatmap.jl")
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

# names for the two axes, so the ticks read as something
vnames = ["gene$(i)" for i in 1:p]

# cca, scca and jive hold the variables in ROWS and the observations in COLUMNS,
# but their LOADINGS are already variables by components, so none of them transpose here
Xt = permutedims(latent * randn(3, 6) .+ 0.3 .* randn(n, 6))    # 6×90
Yt = permutedims(latent * randn(3, 5) .+ 0.3 .* randn(n, 5))    # 5×90

Xs = [permutedims(latent * randn(3, 10) .+ 0.3 .* randn(n, 10)),   # 10×90
      permutedims(latent * randn(3, 8)  .+ 0.3 .* randn(n, 8))]    #  8×90

println("data: X $(size(X)), Xt $(size(Xt)), Yt $(size(Yt))\n")

# ===========================================================================
# ONE LOADINGS HEATMAP PER MODEL
# ===========================================================================

# --- pca -------------------------------------------------------------------
# a dense model, so every cell carries a value
m_pca = pca(X; k = 4)
println("pca      : loadings ", size(m_pca.loadings), " (dense)")
display(plot_loadings_heatmap(m_pca.loadings;
                              varnames = vnames,
                              compnames = ["PC $(j)" for j in 1:4],
                              title = "PCA loadings Heatmap"))

# --- spc -------------------------------------------------------------------
# a sparse model, so the dropped variables read as the midtone
m_spc = spc(X; k = 5, c = sqrt(p) / 2)
println("spc      : nonzeros per loading = ",
        [count(!iszero, m_spc.loadings[:, j]) for j in 1:size(m_spc.loadings, 2)], " of $p")
display(plot_loadings_heatmap(m_spc.loadings;
                              varnames = vnames, nonzero = true,
                              compnames = ["SPC $(j)" for j in 1:5],
                              title = "sparse PCA, selected variables only"))

# the same loadings with every variable kept, to see what nonzero is hiding
display(plot_loadings_heatmap(m_spc.loadings;
                              varnames = vnames,
                              compnames = ["SPC $(j)" for j in 1:5],
                              title = "sparse PCA, all variables"))

# --- pmd -------------------------------------------------------------------
m_pmd = pmd(X; K = 4, sumabs = 0.4)
println("pmd      : nonzeros in v = ", [count(!iszero, m_pmd.v[:, k]) for k in 1:m_pmd.K], " of $p")
display(plot_loadings_heatmap(m_pmd.v;
                              varnames = vnames, nonzero = true,
                              compnames = ["Comp $(k)" for k in 1:m_pmd.K],
                              title = "PMD variable factors"))

# --- plskern ---------------------------------------------------------------
m_pls = plskern(X, Y; nlv = 3)
println("plskern  : P ", size(m_pls.P))
display(plot_loadings_heatmap(m_pls.P;
                              varnames = vnames,
                              compnames = ["LV $(j)" for j in 1:3],
                              title = "kernel PLS, X loadings"))

# --- plsda -----------------------------------------------------------------
m_plsda = plsda(X, y, 3)
println("plsda    : loadings_X ", size(m_plsda.loadings_X))
display(plot_loadings_heatmap(m_plsda.loadings_X;
                              varnames = vnames,
                              compnames = ["X-variate $(j)" for j in 1:3],
                              title = "PLS-DA"))

# --- splsda ----------------------------------------------------------------
m_splsda = splsda(X, y, 3, [5, 5, 5])
println("splsda   : keepX = ", m_splsda.keepX,
        "  nonzeros = ", [count(!iszero, m_splsda.loadings_X[:, k]) for k in 1:3])
display(plot_loadings_heatmap(m_splsda.loadings_X;
                              varnames = vnames, nonzero = true,
                              compnames = ["X-variate $(j)" for j in 1:3],
                              title = "sparse PLS-DA, selected variables only"))

# --- cca -------------------------------------------------------------------
m_cca = cca(Xt, Yt; outdim = 3)
println("cca      : xproj ", size(m_cca.xproj), "  yproj ", size(m_cca.yproj))
display(plot_loadings_heatmap(m_cca.xproj;
                              compnames = ["X-variate $(j)" for j in 1:3],
                              title = "CCA, X directions",ntop = 3))
display(plot_loadings_heatmap(m_cca.yproj;
                              compnames = ["Y-variate $(j)" for j in 1:3],
                              title = "CCA, Y directions"))

# --- scca ------------------------------------------------------------------
m_scca = scca(Xt, Yt; K = 3, penaltyx = 0.5, penaltyz = 0.5)
println("scca     : nonzeros in u = ", [count(!iszero, m_scca.u[:, k]) for k in 1:m_scca.K],
        " of ", size(m_scca.u, 1))
display(plot_loadings_heatmap(m_scca.u;
                              nonzero = false,
                              compnames = ["X-variate $(j)" for j in 1:m_scca.K],
                              title = "sparse CCA, X side"))

# --- jive ------------------------------------------------------------------
m_jive = jive(Xs; r = 2, ri = [1, 1])
println("jive     : U[1] ", size(m_jive.U[1]), "  U[2] ", size(m_jive.U[2]))
display(plot_loadings_heatmap(m_jive.U[2];
                              compnames = ["Joint $(j)" for j in 1:m_jive.r],
                              title = "JIVE, joint loadings of block 1"))

# ===========================================================================
# THE KNOBS
# ===========================================================================

# a subset of the components
display(plot_loadings_heatmap(m_pca.loadings; comps = [1, 3], varnames = vnames,
                              compnames = ["PC $(j)" for j in 1:4],
                              title = "comps = [1, 3]"))

# ntop ranks by the largest loading a variable reaches on ANY component drawn
display(plot_loadings_heatmap(m_pca.loadings; ntop = 2, varnames = vnames,
                              title = "ntop = 2"))

# nonzero and ntop together, the zeros dropped first
display(plot_loadings_heatmap(m_spc.loadings; nonzero = true, ntop = 3, varnames = vnames,
                              title = "nonzero = true, ntop = 3"))

# no names, so both axes keep their index
display(plot_loadings_heatmap(m_pca.loadings; title = "no names"))

# the recipe keywords
display(plot_loadings_heatmap(m_pca.loadings; varnames = vnames,
                              heatmapcolor = :balance, maxnames = 5,
                              title = "heatmapcolor = :balance, maxnames = 5"))

# the `-->` defaults should yield to whatever the caller passes
display(plot_loadings_heatmap(m_pca.loadings; varnames = vnames,
                              title = "overrides: no colorbar, small",
                              colorbar = false, size = (500, 400), guidefontsize = 9,ntop = 10))

# ===========================================================================
# THE GUARDS
# ===========================================================================

println("\n--- guards ---")

# a component out of range
try
    plot_loadings_heatmap(m_pca.loadings; comps = [1, 9])
    println("!! expected an error for comps = [1, 9], none thrown")
catch e
    println("comp out of range      : ", e)
end

# a varnames vector of the wrong length
try
    plot_loadings_heatmap(m_pca.loadings; varnames = ["a", "b"])
    println("!! expected an error for a short varnames vector, none thrown")
catch e
    println("short varnames vector  : ", e)
end

# a compnames vector of the wrong length
try
    plot_loadings_heatmap(m_pca.loadings; compnames = ["a", "b"])
    println("!! expected an error for a short compnames vector, none thrown")
catch e
    println("short compnames vector : ", e)
end

# nonzero on a matrix with nothing selected anywhere
try
    plot_loadings_heatmap(zeros(p, 2); nonzero = true)
    println("!! expected an error for an all zero matrix, none thrown")
catch e
    println("all zero matrix        : ", e)
end

println("\ndone — the sparse models should show mostly midtone with a few warm and cool cells.")