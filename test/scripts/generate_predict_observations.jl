# generate_predict_observations.jl — build the predict-observations fixture and reference.
#
# Run once, by hand:  julia --project=. test/scripts/generate_predict_observations.jl

using BigRiverEssence
using WolfRiverPlots
using Plots
using Helium
using StableRNGs

rng = StableRNG(20240728)

# a response built from the predictors plus noise, so the fit is good but not perfect
n = 80
p = 15
q = 3
X = randn(rng, n, p)
B = randn(rng, p, q)
Y = X * B .+ 0.5 .* randn(rng, n, q)

m = plskern(X, Y; nlv = 5)
Yhat = plskern_predict(m, X)

datadir = joinpath(@__DIR__, "..", "data")
mkpath(datadir)
# observed and predicted are both needed, so both are stored
Helium.writehe(Y, joinpath(datadir, "predict_observations_observed.he"))
Helium.writehe(Yhat, joinpath(datadir, "predict_observations_predicted.he"))

refdir = joinpath(@__DIR__, "..", "ref")
mkpath(refdir)
plot_predict_observations(Y, Yhat)
savefig(joinpath(refdir, "predict_observations_ref.png"))

println("generate_predict_observations: wrote the two .he files and the ref png")