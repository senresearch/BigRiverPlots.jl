# test_biplot.jl — informal check of the biplot, for every model of BigRiverEssence.
#
# Best run from the REPL so the windows stay up:
#   julia> include("test_biplot.jl")
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

# names for the arrows, so the tips read as something
vnames = ["gene$(i)" for i in 1:p]

# cca, scca and jive hold the variables in ROWS and the observations in COLUMNS
Xt = permutedims(latent * randn(3, 6) .+ 0.3 .* randn(n, 6))    # 6×90
Yt = permutedims(latent * randn(3, 5) .+ 0.3 .* randn(n, 5))    # 5×90

Xs = [permutedims(latent * randn(3, 10) .+ 0.3 .* randn(n, 10)),   # 10×90
      permutedims(latent * randn(3, 8)  .+ 0.3 .* randn(n, 8))]    #  8×90

println("data: X $(size(X)), Xt $(size(Xt)), Yt $(size(Yt))")
println("      y $(length(y)) labels in $(length(unique(y))) classes\n")

# ===========================================================================
# ONE BIPLOT PER MODEL
# ===========================================================================

# --- pca -------------------------------------------------------------------
# a dense model, so ntop keeps the arrows from burying the points
m_pca = pca(X; k = 4)
println("pca      : propOFvar = ", round.(m_pca.propOFvar, digits = 3))
display(plot_biplot(pca_transform(m_pca, X), m_pca.loadings;
                    group = y, varnames = vnames, ntop = 5,
                    xlabel = "PC 1 ($(round(100 * m_pca.propOFvar[1], digits = 1))%)",
                    ylabel = "PC 2 ($(round(100 * m_pca.propOFvar[2], digits = 1))%)",
                    title = "PCA biplot"))

# --- spc -------------------------------------------------------------------
# a sparse model, so only the selected variables get an arrow
m_spc = spc(X; k = 4, c = sqrt(p) / 2)
println("spc      : nonzeros per loading = ",
        [count(!iszero, m_spc.loadings[:, j]) for j in 1:size(m_spc.loadings, 2)], " of $p")
display(plot_biplot(((X .- m_spc.mean') ./ m_spc.scale') * m_spc.loadings, m_spc.loadings;
                    group = y, varnames = vnames, nonzero = true,
                    xlabel = "SPC 1 (var=$(round(m_spc.variances[1], digits = 2)))",
                    ylabel = "SPC 2 (var=$(round(m_spc.variances[2], digits = 2)))",
                    title = "sparse PCA biplot"))

# --- pmd -------------------------------------------------------------------
m_pmd = pmd(X; K = 4, sumabs = 0.4)
println("pmd      : nonzeros in v = ", [count(!iszero, m_pmd.v[:, k]) for k in 1:m_pmd.K], " of $p")
display(plot_biplot(m_pmd.u, m_pmd.v;  comps= (1, 2),
                    group = y, varnames = vnames, nonzero = true,
                    xlabel = "Comp 1 (d=$(round(m_pmd.d[1], digits = 2)))",
                    ylabel = "Comp 2 (d=$(round(m_pmd.d[2], digits = 2)))",
                    title = "PMD biplot"))

# --- plskern ---------------------------------------------------------------
m_pls = plskern(X, Y; nlv = 3)
println("plskern  : T ", size(m_pls.T), "  P ", size(m_pls.P))
display(plot_biplot(m_pls.T, m_pls.P;
                    group = y, varnames = vnames, ntop = 8,
                    xlabel = "LV 1", ylabel = "LV 2",
                    title = "kernel PLS biplot"))

# --- plsda -----------------------------------------------------------------
m_plsda = plsda(X, y, 3)
println("plsda    : variates_X ", size(m_plsda.variates_X))
display(plot_biplot(m_plsda.variates_X, m_plsda.loadings_X;
                    group = y, varnames = vnames, ntop = 8,
                    xlabel = "X-variate 1", ylabel = "X-variate 2",
                    title = "PLS-DA biplot"))

# --- splsda ----------------------------------------------------------------
m_splsda = splsda(X, y, 3, [5, 5, 5])
println("splsda   : keepX = ", m_splsda.keepX)
display(plot_biplot(m_splsda.variates_X, m_splsda.loadings_X;
                    group = y, varnames = vnames, nonzero = true,
                    xlabel = "X-variate 1 ($(m_splsda.keepX[1]) vars)",
                    ylabel = "X-variate 2 ($(m_splsda.keepX[2]) vars)",
                    title = "sparse PLS-DA biplot"))

# --- cca -------------------------------------------------------------------
# the SCORES are transposed, the LOADINGS are not
m_cca = cca(Xt, Yt; outdim = 3)
println("cca      : corrs = ", round.(m_cca.corrs, digits = 3))
display(plot_biplot(permutedims(cca_transform(m_cca, Xt, :x)), m_cca.xproj;
                    group = y,
                    xlabel = "X-variate 1 (r=$(round(m_cca.corrs[1], digits = 2)))",
                    ylabel = "X-variate 2 (r=$(round(m_cca.corrs[2], digits = 2)))",
                    title = "CCA biplot, X side"))

# --- scca ------------------------------------------------------------------
m_scca = scca(Xt, Yt; K = 3, penaltyx = 0.5, penaltyz = 0.5)
println("scca     : cors = ", round.(m_scca.cors, digits = 3))
display(plot_biplot(permutedims(Xt) * m_scca.u, m_scca.u;
                    group = y, nonzero = true,
                    xlabel = "X-variate 1 (r=$(round(m_scca.cors[1], digits = 2)))",
                    ylabel = "X-variate 2 (r=$(round(m_scca.cors[2], digits = 2)))",
                    title = "sparse CCA biplot, X side"))

# --- jive ------------------------------------------------------------------
m_jive = jive(Xs; r = 2, ri = [1, 1])
println("jive     : r = ", m_jive.r, "  U[2] ", size(m_jive.U[2]))
display(plot_biplot(permutedims(m_jive.S), m_jive.U[2];
                    group = y,
                    xlabel = "Joint 1", ylabel = "Joint 2",
                    title = "JIVE biplot, block 1"))

display(plot_biplot(permutedims(m_jive.S), m_jive.U[2];
                    group = y,
                    xlabel = "Joint 1", ylabel = "Joint 2",
                    xlims = (-0.5, 0.5),
                    ylims = (-0.5, 0.5),
                    title = "JIVE biplot, block 1"))

# ===========================================================================
# THE KNOBS
# ===========================================================================

S_pca = pca_transform(m_pca, X)

# no grouping at all, so one series, no legend and no ellipse
display(plot_biplot(S_pca, m_pca.loadings; varnames = vnames, ntop = 8,
                    title = "no group, no ellipse"))

# the ellipses turned off, the points left bare
display(plot_biplot(S_pca, m_pca.loadings; group = y, varnames = vnames, ntop = 8,
                    ellipse = false, title = "ellipse = false"))

# a tighter and a wider ellipse
display(plot_biplot(S_pca, m_pca.loadings; group = y, varnames = vnames, ntop = 8,
                    nstd = 1.0, title = "nstd = 1.0"))
display(plot_biplot(S_pca, m_pca.loadings; group = y, varnames = vnames, ntop = 8,
                    nstd = 3.0, title = "nstd = 3.0"))

# the arrows unnamed
display(plot_biplot(S_pca, m_pca.loadings; group = y, varnames = vnames, ntop = 8,
                    arrowlabels = false, title = "arrowlabels = false"))

# every variable gets an arrow, which is what ntop is there to prevent
display(plot_biplot(S_pca, m_pca.loadings; group = y, varnames = vnames,
                    title = "every arrow, no ntop"))

# a different pair of components
display(plot_biplot(S_pca, m_pca.loadings; comps = (1, 3), group = y, varnames = vnames,
                    ntop = 8, xlabel = "PC 1", ylabel = "PC 3",
                    title = "comps = (1, 3)"))

# the arrows scaled by hand rather than onto the cloud
display(plot_biplot(S_pca, m_pca.loadings; group = y, varnames = vnames, ntop = 8,
                    arrowscale = 3.0, title = "arrowscale = 3.0"))
display(plot_biplot(S_pca, m_pca.loadings; group = y, varnames = vnames, ntop = 8,
                    arrowscale = 15.0, title = "arrowscale = 15.0"))

# the recipe keywords
display(plot_biplot(S_pca, m_pca.loadings; group = y, varnames = vnames, ntop = 8,
                    arrowcolor = "#d7191c", origincolor = :black,
                    title = "arrowcolor and origincolor"))

# no varnames, so the arrows are named by their index
display(plot_biplot(S_pca, m_pca.loadings; group = y, ntop = 8,
                    title = "no varnames"))

# the `-->` defaults should yield to whatever the caller passes
display(plot_biplot(S_pca, m_pca.loadings; group = y, varnames = vnames, ntop = 8,
                    title = "overrides: bigger markers, small canvas",
                    marker = 9, size = (600, 400), legend = :topleft))

# ===========================================================================
# THE GUARDS
# ===========================================================================

println("\n--- guards ---")

# comps out of range
try
    plot_biplot(S_pca, m_pca.loadings; comps = (1, 9))
    println("!! expected an error for comps = (1, 9), none thrown")
catch e
    println("comps out of range     : ", e)
end

# a varnames vector of the wrong length
try
    plot_biplot(S_pca, m_pca.loadings; varnames = ["a", "b"])
    println("!! expected an error for a short varnames vector, none thrown")
catch e
    println("short varnames vector  : ", e)
end

# a group vector of the wrong length
try
    plot_biplot(S_pca, m_pca.loadings; group = ["a", "b"])
    println("!! expected an error for a short group vector, none thrown")
catch e
    println("short group vector     : ", e)
end

# nonzero on loadings with nothing selected on either component
try
    plot_biplot(S_pca, zeros(p, 4); nonzero = true)
    println("!! expected an error for all zero loadings, none thrown")
catch e
    println("all zero loadings      : ", e)
end

# a class of fewer than three observations has no ellipse, but should not fail
gsmall = vcat(["solo"], repeat(["big"], n - 1))
display(plot_biplot(S_pca, m_pca.loadings; group = gsmall, varnames = vnames, ntop = 8,
                    title = "a class of one, drawn without an ellipse"))
println("class of one           : drawn, no ellipse traced")

println("\ndone — each biplot should show three colored clusters, each ringed by its own ellipse,")
println("with named arrows reaching out from the origin.")