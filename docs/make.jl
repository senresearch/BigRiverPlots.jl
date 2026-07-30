using BigRiverPlots
using BigRiverEssence   # the example blocks fit models from here
using Documenter

# copy readme into index.md
open(joinpath(@__DIR__, "src", "index.md"), "w") do io
    write(io, read(joinpath(@__DIR__, "..", "README.md"), String))
end

# copy the banner image the readme links to
mkpath(joinpath(@__DIR__, "src", "images"))
cp(joinpath(@__DIR__, "..", "images", "banner.svg"),
   joinpath(@__DIR__, "src", "images", "banner.svg"); force = true)

# copy the assets confidence.md links to
cp(joinpath(@__DIR__, "..", "images", "confidence_example.svg"),
   joinpath(@__DIR__, "src", "images", "confidence_example.svg"); force = true)
cp(joinpath(@__DIR__, "..", "LICENSE"),
   joinpath(@__DIR__, "src", "LICENSE"); force = true)   

makedocs(;
    modules = [BigRiverPlots],
    sitename = "BigRiverPlots.jl",
    pages = [
        "Home" => "index.md",
        "Biplot" => "biplot.md",
        "Confidence" => "confidence.md",
        "Grouped Correlation" => "grouped_correlation.md",
        "JIVE Variance" => "jive_variance.md",
        "Loadings" => "loadings.md",
        "Loadings Heatmap" => "loadings_heatmap.md",
        "Mosaic" => "mosaic.md",
        "Pairs" => "pairs.md",
        "Predict Observations" => "predicted_observations.md",
        "Scores" => "scores.md",
        "Scree" => "scree.md",
        "Sparsity" => "sparse.md",
        "Vip" => "vip.md",
        "API Reference" => "api.md", 
    ],
)

deploydocs(;
    repo = "github.com/senresearch/BigRiverPlots.jl.git",
    devbranch = "main",
    devurl = "dev",
)