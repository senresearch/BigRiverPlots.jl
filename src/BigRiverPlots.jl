module BigRiverPlots

# dependent packages 
using DataFrames, Statistics, LinearAlgebra
using RecipesBase

# utils functions
include("./utils.jl");
export get_levels, check_comps

# confidence functions
include("./confidence/confidence_recipe.jl");
export confidenceplot, confidenceplot!, ConfidencePlot

include("./confidence/plot_confidence.jl");
export plot_confidence, plot_confidence!

# scores functions
include("./scores/scores_helpers.jl");
export get_scores_coords

include("./scores/scores_recipe.jl");
export scoresplot, scoresplot!, ScoresPlot

include("./scores/plot_scores.jl");
export plot_scores, plot_scores!

# loadings functions
include("./loadings/loadings_helpers.jl");
export get_loadings_coords

include("./loadings/loadings_recipe.jl");
export loadingsplot, loadingsplot!, LoadingsPlot

include("./loadings/plot_loadings.jl");
export plot_loadings, plot_loadings!

# loadings heatmap functions
include("./loadings_heatmap/loadings_heatmap_helpers.jl");
export get_loadings_heatmap_coords

include("./loadings_heatmap/loadings_heatmap_recipe.jl");
export loadingsheatmapplot, loadingsheatmapplot!, LoadingsHeatmapPlot

include("./loadings_heatmap/plot_loadings_heatmap.jl");
export plot_loadings_heatmap, plot_loadings_heatmap!

# pairs functions
include("./pairs/pairs_helpers.jl");
export get_pairs_coords

include("./pairs/pairs_recipe.jl");
export pairsplot, pairsplot!, PairsPlot

include("./pairs/plot_pairs.jl");
export plot_pairs, plot_pairs!

# biplot functions
include("./biplot/biplot_helpers.jl");
export get_biplot_coords, get_ellipse_coords

include("./biplot/biplot_recipe.jl");
export biplot, biplot!, BiPlot

include("./biplot/plot_biplot.jl");
export plot_biplot, plot_biplot!

# scree functions
include("./scree/scree_helpers.jl");
export get_scree_coords

include("./scree/scree_recipe.jl");
export screeplot, screeplot!, ScreePlot

include("./scree/plot_scree.jl");
export plot_scree, plot_scree!

# vip functions
include("./vip/vip_helpers.jl");
export get_vip_coords

include("./vip/vip_recipe.jl");
export vipplot, vipplot!, VipPlot

include("./vip/plot_vip.jl");
export plot_vip, plot_vip!

# sparsity functions
include("./sparsity/sparsity_helpers.jl");
export get_sparsity_coords

include("./sparsity/sparsity_recipe.jl");
export sparsityplot, sparsityplot!, SparsityPlot

include("./sparsity/plot_sparsity.jl");
export plot_sparsity, plot_sparsity!

# predict observations functions
include("./predict_observations/predict_observations_helpers.jl");
export get_predict_observations_coords

include("./predict_observations/predict_observations_recipe.jl");
export predictobsplot, predictobsplot!, PredictObsPlot

include("./predict_observations/plot_predict_observations.jl");
export plot_predict_observations, plot_predict_observations!

# jive variance functions
include("./jive_variance/jive_variance_helpers.jl");
export get_jive_variance_coords

include("./jive_variance/jive_variance_recipe.jl");
export jivevarianceplot, jivevarianceplot!, JiveVariancePlot

include("./jive_variance/plot_jive_variance.jl");
export plot_jive_variance, plot_jive_variance!

# mosaic functions
include("./mosaic/mosaic_helpers.jl");
export get_mosaic_coords

include("./mosaic/mosaic_recipe.jl");
export mosaicplot, mosaicplot!, MosaicPlot

include("./mosaic/plot_mosaic.jl");
export plot_mosaic, plot_mosaic!


end # module BigRiverPlots
