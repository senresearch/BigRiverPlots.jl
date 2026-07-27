# test_vip.jl — informal check of the VIP plot, for the discriminant models of
# BigRiverEssence.
#
# Best run from the REPL so the windows stay up:
#   julia> include("test_vip.jl")
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

# three latent signals drive the features, and the class is read off the first, so a
# handful of variables should stand out above the VIP threshold. p is set large so the
# sorted bars read as a curve, as they do on real data
n = 120
p = 200
latent = randn(n, 3)

X = latent * randn(3, p) .+ 0.3 .* randn(n, p)
y = [latent[i, 1] > 0.4 ? "a" : latent[i, 1] < -0.4 ? "c" : "b" for i in 1:n]

vnames = ["gene$(i)" for i in 1:p]

println("data: X $(size(X)),  y in classes ", sort(unique(y)), "\n")

# ===========================================================================
# ONE VIP PLOT PER DISCRIMINANT MODEL
# ===========================================================================

# --- plsda -----------------------------------------------------------------
# many variables, so the y-axis is bare and the sorted bars read as a curve
m_plsda = plsda(X, y, 3)
V_plsda = vip(m_plsda)
println("plsda    : vip ", size(V_plsda), "  overall > 1: ",
        count(>(1), V_plsda[:, end]), " of $p")
display(plot_vip(V_plsda;
                 xlabel = "VIP ($(m_plsda.ncomp) axes)",
                 title = "PLS-DA, Variable Importance in Projection"))


display(plot_vip(V_plsda; comp=3,
                 # --- the threshold line ---
                 threshold = 1.2,              # shift it off 1.0
                 thresholdcolor = :yellow,       # its color
                 thresholdline = true,         # or false to remove it entirely

                 # --- how many variables on the y-axis ---
                 ntop = 30,                    # keep only the top 30 by VIP
                 # above = true,               # or: keep only those above the threshold

                 # --- the bars ---
                 vipcolor = "#6a51a3",         # fill
                 vipedgecolor = :black,         # outline

                 # --- labels / frame (plain Plots attributes) ---
                 xlabel = "VIP ($(m_plsda.ncomp) axes)",
                 title = "PLS-DA VIP"))                 

# --- splsda ----------------------------------------------------------------
m_splsda = splsda(X, y, 3, [30, 30, 30])
V_splsda = vip(m_splsda)
println("splsda   : vip ", size(V_splsda), "  overall > 1: ",
        count(>(1), V_splsda[:, end]), " of $p")
display(plot_vip(V_splsda;  
                 xlabel = "VIP ($(m_splsda.ncomp) axes)",
                 title = "sparse PLS-DA, Variable Importance in Projection"))

# ===========================================================================
# THE KNOBS
# ===========================================================================

# a single component rather than the overall, cumulative, VIP
display(plot_vip(V_plsda; comp = 1,
                 xlabel = "VIP (component 1)", title = "comp = 1"))

# only the important variables, those above the threshold
display(plot_vip(V_plsda; above = true,
                 title = "above = true, important only"))

# the top few, which brings the names back since they now fit
display(plot_vip(V_plsda; ntop = 20, varnames = vnames,
                 title = "ntop = 20, named"))

# the threshold line removed
display(plot_vip(V_plsda; thresholdline = false,
                 title = "thresholdline = false"))

# a threshold moved off one
display(plot_vip(V_plsda; threshold = 1.5,
                 title = "threshold = 1.5"))

# the recipe keywords
display(plot_vip(V_plsda; ntop = 20, varnames = vnames,
                 vipcolor = "#6a51a3", vipedgecolor = "#3f007d", thresholdcolor = :orange,
                 title = "vipcolor, vipedgecolor and thresholdcolor"))

# the `-->` defaults should yield to whatever the caller passes
display(plot_vip(V_plsda;
                 title = "overrides: wider, big font",
                 size = (800, 500), guidefontsize = 10))

# ===========================================================================
# THE GUARDS
# ===========================================================================

println("\n--- guards ---")

# a component out of range
try
    plot_vip(V_plsda; comp = 9)
    println("!! expected an error for comp = 9, none thrown")
catch e
    println("comp out of range      : ", e)
end

# a varnames vector of the wrong length
try
    plot_vip(V_plsda; varnames = ["a", "b"])
    println("!! expected an error for a short varnames vector, none thrown")
catch e
    println("short varnames vector  : ", e)
end

# above the threshold on a matrix where nothing clears it
try
    plot_vip(zeros(p, 3); above = true)
    println("!! expected an error for nothing above the threshold, none thrown")
catch e
    println("nothing above one      : ", e)
end

println("\ndone — the curve should cross the dashed line where the VIP falls through one.")