# test_sparsity.jl — informal check of the sparsity plot, for the penalized models of
# BigRiverEssence.
#
# Best run from the REPL so the windows stay up:
#   julia> include("test_sparsity.jl")
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

# three latent signals drive the features, p large enough that the penalty leaves most
# variables at zero and the counts are well below p
n = 90
p = 40
latent = randn(n, 3)

X = latent * randn(3, p) .+ 0.3 .* randn(n, p)
y = [latent[i, 1] > 0.4 ? "a" : latent[i, 1] < -0.4 ? "c" : "b" for i in 1:n]

# cca, scca and jive hold the variables in ROWS and the observations in COLUMNS
Xt = permutedims(latent * randn(3, 12) .+ 0.3 .* randn(n, 12))    # 12×90
Yt = permutedims(latent * randn(3, 10) .+ 0.3 .* randn(n, 10))    # 10×90

println("data: X $(size(X)), Xt $(size(Xt)), Yt $(size(Yt))\n")

# ===========================================================================
# ONE SPARSITY PLOT PER PENALIZED MODEL
# ===========================================================================

# --- spc -------------------------------------------------------------------

m_spc = spc(X; k = 4, c = sqrt(p) / 2)
println("spc      : counts = ", [count(!iszero, m_spc.loadings[:, j]) for j in 1:4], " of $p")
display(plot_sparsity(m_spc.loadings; comps = [1,2,3],
                      compnames = ["SPC $(j)" for j in 1:4],
                      title = "sparse PCA, variables selected per component"))

# --- pmd, the variable side ------------------------------------------------
m_pmd = pmd(X; K = 4, sumabs = 0.4)
println("pmd (v)  : counts = ", [count(!iszero, m_pmd.v[:, k]) for k in 1:m_pmd.K], " of $p")
display(plot_sparsity(m_pmd.v;
                      compnames = ["Comp $(k)" for k in 1:m_pmd.K],
                      title = "PMD, variables selected (v)"))

# --- pmd, the sample side --------------------------------------------------
# PMD penalizes both factors, so the samples are selected too
println("pmd (u)  : counts = ", [count(!iszero, m_pmd.u[:, k]) for k in 1:m_pmd.K], " of $n")
display(plot_sparsity(m_pmd.u;
                      compnames = ["Comp $(k)" for k in 1:m_pmd.K],
                      ylabel = "samples selected",
                      title = "PMD, samples selected (u)"))

# --- splsda ----------------------------------------------------------------
m_splsda = splsda(X, y, 3, [10, 15, 20])
println("splsda   : keepX = ", m_splsda.keepX,
        "  counts = ", [count(!iszero, m_splsda.loadings_X[:, k]) for k in 1:3])
display(plot_sparsity(m_splsda.loadings_X;comps = [3,2,1],
                      compnames = ["X-variate $(j)" for j in 1:3],
                      title = "sparse PLS-DA, variables selected per component"))

# --- scca, the X side ------------------------------------------------------
m_scca = scca(Xt, Yt; K = 3, penaltyx = 0.5, penaltyz = 0.5)
println("scca (u) : counts = ", [count(!iszero, m_scca.u[:, k]) for k in 1:m_scca.K],
        " of ", size(m_scca.u, 1))
display(plot_sparsity(m_scca.u;
                      compnames = ["CC $(j)" for j in 1:m_scca.K],
                      title = "sparse CCA, X variables selected"))

# ===========================================================================
# THE KNOBS
# ===========================================================================

# the fraction selected rather than the count
display(plot_sparsity(m_spc.loadings; asfraction = true,
                      compnames = ["SPC $(j)" for j in 1:4],
                      ylabel = "fraction of variables selected",
                      title = "asfraction = true"))

# only the leading components
display(plot_sparsity(m_spc.loadings; ncomp = 2,
                      compnames = ["SPC $(j)" for j in 1:4],
                      title = "ncomp = 2"))

# the count labels removed
display(plot_sparsity(m_spc.loadings; labelcounts = false,
                      compnames = ["SPC $(j)" for j in 1:4],
                      title = "labelcounts = false"))

# no names, so the components keep their index
display(plot_sparsity(m_spc.loadings; title = "no compnames"))

# the recipe keyword
display(plot_sparsity(m_spc.loadings; sparsitycolor = "#238b45",
                      compnames = ["SPC $(j)" for j in 1:4],
                      title = "sparsitycolor"))

# the `-->` defaults should yield to whatever the caller passes
display(plot_sparsity(m_spc.loadings; compnames = ["SPC $(j)" for j in 1:4],
                      title = "overrides: small, big font",
                      size = (500, 400), guidefontsize = 10))

# ===========================================================================
# THE GUARDS
# ===========================================================================

println("\n--- guards ---")

# a compnames vector of the wrong length
try
    plot_sparsity(m_spc.loadings; compnames = ["a", "b"])
    println("!! expected an error for a short compnames vector, none thrown")
catch e
    println("short compnames vector : ", e)
end

println("\ndone — the sparse models should show bars well below the total variable count,")
println("and a dense loading matrix would show full bars, which is why the dense models have none.")