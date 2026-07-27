using WolfRiverPlots
using Distributions, Random
using Plots

########
# Data #
########

Random.seed!(1203)

x = randn(7)

y = repeat([""], 7)
y = map(x -> randstring('A':'Z', 2), y)

ε = rand(Uniform(0.1,0.25), 7)

########
# Plot #
########
plot_confidence(x, y, ε,
    title = "Confidence Plot\n",
    xlabel = "Effect Size",
    ylabel = "Variables")
savefig(joinpath(@__DIR__, "..", "images", "confidence_example.svg"))