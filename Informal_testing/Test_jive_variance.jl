# test_jive_variance.jl — informal check of the JIVE variance explained plot.
#
# Best run from the REPL so the windows stay up:
#   julia> include("test_jive_variance.jl")
#
# (needs Plots, BigRiverEssence and WolfRiverPlots in the active environment)

using Plots
using BigRiverEssence
using WolfRiverPlots
using LinearAlgebra, Statistics, Random

Random.seed!(1234)

# ===========================================================================
# DATA
# ===========================================================================

# a shared joint signal across the blocks, plus a signal of each block's own, so each
# bar carries a real joint part, a real individual part, and a residual. Blocks hold
# the variables in ROWS and the observations in COLUMNS, as jive expects
n = 120
joint_signal = randn(2, n)                 # rank-2 signal shared by every block

Xs = Matrix{Float64}[
    randn(30, 2) * joint_signal .+ randn(30, 4) * randn(4, n) .+ 0.4 .* randn(30, n),
    randn(25, 2) * joint_signal .+ randn(25, 4) * randn(4, n) .+ 0.4 .* randn(25, n),
    randn(40, 2) * joint_signal .+ randn(40, 4) * randn(4, n) .+ 0.4 .* randn(40, n),
]

nm = ["Expression", "Methylation", "miRNA"]
println("data: ", length(Xs), " blocks of sizes ", [size(b) for b in Xs], "\n")

# ===========================================================================
# THE JIVE MODEL
# ===========================================================================

m_jive = jive(Xs; r = 2, ri = [4, 4, 4])
println("jive     : r = ", m_jive.r, "  ri = ", m_jive.ri)

# ===========================================================================
# SCALE THE BLOCKS THE WAY jive DOES  (see the JIVE tutorial)
# ===========================================================================

# row-center each block, then Frobenius-normalize so no block dominates. This is the
# scale the fitted J and A live on, so the variance fractions must be measured against it
nel   = [size(X, 1) * size(X, 2) for X in Xs]
sum_n = sum(nel)
Dat   = [ let Xi = X .- mean(X, dims = 2); Xi ./ (norm(Xi) * sqrt(sum_n)); end
          for X in Xs ]

# a quick print of the fractions, to compare against the bars
for i in 1:length(Dat)
    total = norm(Dat[i])^2
    vj = norm(m_jive.J[i])^2 / total
    vi = norm(m_jive.A[i])^2 / total
    println("  block $(i): joint ", round(vj, digits = 3),
            "  individual ", round(vi, digits = 3),
            "  residual ", round(1 - vj - vi, digits = 3))
end

# ===========================================================================
# THE PLOT
# ===========================================================================

display(plot_jive_variance(Dat, m_jive.J, m_jive.A;
                           blocknames = nm,
                           title = "Variation Explained"))

# ===========================================================================
# THE KNOBS
# ===========================================================================

# no names, so the blocks keep their index
display(plot_jive_variance(Dat, m_jive.J, m_jive.A;
                           title = "no blocknames"))

# the recipe keywords, a lighter scheme
display(plot_jive_variance(Dat, m_jive.J, m_jive.A;
                           blocknames = nm,
                           jointcolor = "#08519c",
                           individualcolor = "#3182bd",
                           residualcolor = "#bdd7e7",
                           title = "a colored scheme"))

# the `-->` defaults should yield to whatever the caller passes
display(plot_jive_variance(Dat, m_jive.J, m_jive.A;
                           blocknames = nm,
                           title = "overrides: legend inside, small",
                           legend = :topright, size = (500, 400)))

# ===========================================================================
# THE GUARDS
# ===========================================================================

println("\n--- guards ---")

# a blocknames vector of the wrong length
try
    plot_jive_variance(Dat, m_jive.J, m_jive.A; blocknames = ["only one"])
    println("!! expected an error for a short blocknames vector, none thrown")
catch e
    println("short blocknames vector: ", e)
end

# a joint vector of the wrong number of blocks
try
    plot_jive_variance(Dat, m_jive.J[1:2], m_jive.A)
    println("!! expected an error for too few joint blocks, none thrown")
catch e
    println("wrong block count      : ", e)
end

println("\ndone — each bar should stack residual, individual and joint to a full height of one,")
println("and the joint part should be real, since the blocks share a signal.")