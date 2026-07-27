using WolfRiverPlots
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
    modules = [WolfRiverPlots],
    sitename = "WolfRiverPlots.jl",
    pages = [
        "Home" => "index.md",
        "Scores" => "scores.md",
        "Loadings" => "loadings.md",
        "Biplot" => "biplot.md",
        "Scree" => "scree.md",
        "Loadings Heatmap" => "loadings_heatmap.md",
        "Pairs" => "pairs.md",
        "Vip" => "vip.md",
        "Sparsity" => "sparse.md",
        "Predict Observations" => "predicted_observations.md",
        "JIVE Variance" => "jive_variance.md",
        "Mosaic" => "mosaic.md",
        "Confidence" => "confidence.md",
        "API Reference" => "api.md", 
    ],
)

deploydocs(;
    repo = "github.com/senresearch/WolfRiverPlots.jl.git",
    devbranch = "main",
    devurl = "dev",
)