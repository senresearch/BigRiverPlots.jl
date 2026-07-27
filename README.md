# BigRiverPlots


[![CI](https://github.com/senresearch/BigRiverPlots.jl/actions/workflows/ci.yml/badge.svg)](https://github.com/senresearch/BigRiverPlots.jl/actions/workflows/ci.yml)
[![codecov](https://codecov.io/gh/senresearch/BigRiverPlots.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/senresearch/BigRiverPlots.jl)
[![Docs-stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://senresearch.github.io/BigRiverPlots.jl/stable)
[![Docs-dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://senresearch.github.io/BigRiverPlots.jl/dev)
[![Pkg Status](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)


## Description

`BigRiverPlots.jl` is a versatile plotting package built in the Julia 
programming language. The package consists of specific plotting recipes, 
designed to streamline data visualization and enhance the process of statistical analysis.

![BigRiverPlots example plots](images/banner.svg)

Every plot is built on [RecipesBase](https://github.com/JuliaPlots/RecipesBase.jl), so
the recipes stay dormant until the user loads Plots. They are model-agnostic: each takes
the matrices a model produces — a scores matrix, a loadings matrix, a vector of
variances — rather than the model object itself, so any decomposition that yields those
can be drawn with them.

The package currently provides the following plots:

* Biplot — the observations and the variable loadings on one canvas
* Confidence plot — the uncertainty region around each observation or group mean, shown as a band
* JIVE variance plot — the joint, individual, and residual variation of each block
* Loadings heatmap — every variable against every component
* Loadings plot — the contribution of each variable to one component
* Mosaic plot — a contingency table drawn as tiles of proportional area
* Pairs plot — a grid crossing several components at once
* Predicted versus observed plot — the fit of a regression
* Scores plot — the observations in the space of two components
* Scree plot — the variance carried by each component
* Sparsity plot — the number of variables each component keeps
* VIP plot — the Variable Importance in Projection of a discriminant model

## Installation

The `BigRiverPlots` package can be installed by running:

```julia
using Pkg
Pkg.add("BigRiverPlots")
```

or from the Julia REPL, press `]` to enter pkg mode, and execute:


```
add BigRiverPlots
```

For the most recent (development) version, use:
```
using Pkg
Pkg.add(url = "https://github.com/senresearch/BigRiverPlots.jl", rev="main")
```

## Contributing

We welcome contributions that improve documentation, performance, testing, and functionality. 
Users can contribute by opening an issue or submitting a pull request.

## Questions

If you have questions about contributing or using `BigRiverPlots` package, please communicate with the authors via GitHub.

