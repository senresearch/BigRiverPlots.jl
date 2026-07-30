# generate_all.jl — regenerate every fixture and reference image.
#
# Run once, by hand, after any change that should move the fixtures or the reference
# images (a change to a helper, a recipe, or the data a generator builds):
#   julia --project=. test/scripts/generate_all.jl
#
# It simply includes each generate_*.jl in turn. The tests never run this.

@info "regenerating all fixtures and reference images"

include("generate_scores.jl")
include("generate_loadings.jl")
include("generate_loadings_heatmap.jl")
include("generate_pairs.jl")
include("generate_biplot.jl")
include("generate_scree.jl")
include("generate_vip.jl")
include("generate_sparsity.jl")
include("generate_predict_observations.jl")
include("generate_jive_variance.jl")
include("generate_mosaic.jl")
include("generate_grouped_correlation.jl")

@info "done"