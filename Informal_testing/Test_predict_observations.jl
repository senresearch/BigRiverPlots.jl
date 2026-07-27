# test_predict_observations.jl — informal check of the predicted versus observed plot,
# for the regression model of BigRiverEssence.
#
# Best run from the REPL so the windows stay up:
#   julia> include("test_predict_observations.jl")
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

# a response built from the predictors plus noise, so the model has a real signal to
# fit and the points fall near, but not on, the line of perfect prediction
n = 120
p = 15
q = 3

Xall = randn(n, p)
B = randn(p, q)
Yall = Xall * B .+ 0.5 .* randn(n, q)

# a train and a test split, so the honest test fit can be shown next to the training one
ntrain = 80
Xtr, Xte = Xall[1:ntrain, :], Xall[ntrain+1:end, :]
Ytr, Yte = Yall[1:ntrain, :], Yall[ntrain+1:end, :]

println("data: X $(size(Xall)), Y $(size(Yall)),  train $(ntrain), test $(n - ntrain)\n")

# ===========================================================================
# THE REGRESSION MODEL
# ===========================================================================

# --- plskern, training fit -------------------------------------------------
m_pls = plskern(Xtr, Ytr; nlv = 5)
Yhat_tr = plskern_predict(m_pls, Xtr)
println("plskern  : trained on $(ntrain), predicting $(size(Yhat_tr))")
display(plot_predict_observations(Ytr, Yhat_tr;
                                  title = "PLS training fit, response 1"))

# --- plskern, test fit -----------------------------------------------------
# the honest picture: observations the coefficients never saw
Yhat_te = plskern_predict(m_pls, Xte)
display(plot_predict_observations(Yte, Yhat_te;
                                  title = "PLS test fit, response 1"))

# --- each response of the multivariate regression --------------------------
for r in 1:q
    display(plot_predict_observations(Yte, Yhat_te; resp = r,
                                      title = "PLS test fit, response $(r)"))
end

# ===========================================================================
# THE KNOBS
# ===========================================================================

# the reference line removed
display(plot_predict_observations(Ytr, Yhat_tr; refline = false,
                                  title = "refline = false"))

# the R squared annotation removed
display(plot_predict_observations(Ytr, Yhat_tr; showr2 = false,
                                  title = "showr2 = false"))

# the recipe keywords
display(plot_predict_observations(Ytr, Yhat_tr; pointcolor = "#31a354", linecolor_ = :red,
                                  title = "pointcolor and linecolor_"))

# the `-->` defaults should yield to whatever the caller passes
display(plot_predict_observations(Ytr, Yhat_tr;
                                  title = "overrides: bigger markers, not square",
                                  marker = 8, aspect_ratio = :none, size = (700, 450)))

# a nicely labelled call
display(plot_predict_observations(Yte, Yhat_te;
                                  xlabel = "observed response 1", ylabel = "predicted response 1",
                                  title = "PLS test fit"))

# ===========================================================================
# THE GUARDS
# ===========================================================================

println("\n--- guards ---")

# a response out of range
try
    plot_predict_observations(Ytr, Yhat_tr; resp = 9)
    println("!! expected an error for resp = 9, none thrown")
catch e
    println("resp out of range      : ", e)
end

# observed and predicted of different sizes
try
    plot_predict_observations(Ytr, Yhat_te)
    println("!! expected an error for mismatched sizes, none thrown")
catch e
    println("mismatched sizes       : ", e)
end

println("\ndone — the training fit should hug the line, the test fit should scatter a little wider.")