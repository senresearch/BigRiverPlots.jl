# test_scree.jl — informal check of the scree plot, for the models of BigRiverEssence
# that store a per component strength.
#
# Best run from the REPL so the windows stay up:
#   julia> include("test_scree.jl")
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

# three latent signals drive every block, so the scree should fall after three
n = 90
p = 20
latent = randn(n, 3)

X = latent * randn(3, p) .+ 0.3 .* randn(n, p)

# cca, scca and jive hold the variables in ROWS and the observations in COLUMNS
Xt = permutedims(latent * randn(3, 6) .+ 0.3 .* randn(n, 6))    # 6×90
Yt = permutedims(latent * randn(3, 5) .+ 0.3 .* randn(n, 5))    # 5×90

Xs = [permutedims(latent * randn(3, 10) .+ 0.3 .* randn(n, 10)),   # 10×90
      permutedims(latent * randn(3, 8)  .+ 0.3 .* randn(n, 8))]    #  8×90

println("data: X $(size(X)), Xt $(size(Xt)), Yt $(size(Yt))\n")

# ===========================================================================
# ONE SCREE PLOT PER MODEL THAT HAS ONE
# ===========================================================================

# --- pca -------------------------------------------------------------------
# the raw variances, expect a drop after the third bar
m_pca = pca(X; k = 8)
println("pca      : variances = ", round.(m_pca.variances, digits = 2))
display(plot_scree(m_pca.variances;
                   compnames = ["PC $(j)" for j in 1:8],
                   ylabel = "variance", title = "PCA scree"))

# ---- the four core variations --------------------------------------------

# 1. variance, with the line (the default)
display(plot_scree(m_pca.variances;
                   compnames = ["PC $(j)" for j in 1:8],
                   ylabel = "variance", title = "variance + line"))

# 2. variance, no line — bars alone
display(plot_scree(m_pca.variances;
                   compnames = ["PC $(j)" for j in 1:8],
                   showline = false,
                   ylabel = "variance", title = "variance, bars only"))

# 3. cumulative proportion, with the line
display(plot_scree(m_pca.propOFvar;
                   compnames = ["PC $(j)" for j in 1:8],
                   cumulative = true,
                   ylabel = "cumulative proportion", title = "cumulative + line"))

# 4. cumulative proportion, no line
display(plot_scree(m_pca.propOFvar;
                   compnames = ["PC $(j)" for j in 1:8],
                   cumulative = true, showline = false,
                   ylabel = "cumulative proportion", title = "cumulative, bars only"))

# the proportion of variance, cumulated into the rising curve read against a threshold
display(plot_scree(m_pca.propOFvar;
                   compnames = ["PC $(j)" for j in 1:8], cumulative = true,
                   ylabel = "cumulative proportion of variance",
                   title = "PCA cumulative variance"))

# --- spc -------------------------------------------------------------------
m_spc = spc(X; k = 8, c = sqrt(p) / 2)
println("spc      : variances = ", round.(m_spc.variances, digits = 2))
display(plot_scree(m_spc.variances; 
                   compnames = ["SPC $(j)" for j in 1:8],
                   ylabel = "variance", title = "sparse PCA scree"))

# --- pmd -------------------------------------------------------------------
m_pmd = pmd(X; K = 6, sumabs = 0.4)
println("pmd      : d = ", round.(m_pmd.d, digits = 2))
display(plot_scree(m_pmd.d; cumulative = false,
                   compnames = ["Comp $(k)" for k in 1:m_pmd.K],
                   ylabel = "weight d", title = "PMD scree"))

# --- cca -------------------------------------------------------------------
m_cca = cca(Xt, Yt; outdim = 5)
println("cca      : corrs = ", round.(m_cca.corrs, digits = 3))
display(plot_scree(m_cca.corrs;
                   compnames = ["CC $(j)" for j in 1:length(m_cca.corrs)],
                   ylabel = "canonical correlation", title = "CCA scree"))

# --- scca ------------------------------------------------------------------
m_scca = scca(Xt, Yt; K = 5, penaltyx = 0.5, penaltyz = 0.5)
println("scca     : cors = ", round.(m_scca.cors, digits = 3))
display(plot_scree(m_scca.cors;
                   compnames = ["CC $(j)" for j in 1:m_scca.K],
                   ylabel = "variate correlation", title = "sparse CCA scree"))

# ===========================================================================
# THE KNOBS
# ===========================================================================

# the line removed, bars alone
display(plot_scree(m_pca.variances; compnames = ["PC $(j)" for j in 1:8],
                   showline = false, ylabel = "variance",
                   title = "showline = false"))

# only the leading components, the tail dropped
display(plot_scree(m_pca.variances; ncomp = 4, compnames = ["PC $(j)" for j in 1:8],
                   ylabel = "variance", title = "ncomp = 4"))

# no names, so the components keep their index
display(plot_scree(m_pca.variances; ylabel = "variance", title = "no compnames"))

# the recipe keywords
display(plot_scree(m_pca.variances; compnames = ["PC $(j)" for j in 1:8],
                   barcolor = "#fdae6b", linecolor_ = "#e6550d",
                   ylabel = "variance", title = "barcolor and linecolor_"))

# the `-->` defaults should yield to whatever the caller passes
display(plot_scree(m_pca.variances; compnames = ["PC $(j)" for j in 1:8],
                   ylabel = "variance", title = "overrides: small, big font",
                   size = (500, 400), guidefontsize = 10, ylims = (0, 30)))

# ===========================================================================
# THE GUARDS
# ===========================================================================

println("\n--- guards ---")

# a compnames vector of the wrong length
try
    plot_scree(m_pca.variances; compnames = ["a", "b"])
    println("!! expected an error for a short compnames vector, none thrown")
catch e
    println("short compnames vector : ", e)
end

println("\ndone — every scree should fall after the third component, since the data has three signals.")