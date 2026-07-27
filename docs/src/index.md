# BigRiverPlots


[![CI](https://github.com/senresearch/BigRiverPlots.jl/actions/workflows/ci.yml/badge.svg)](https://github.com/senresearch/BigRiverPlots.jl/actions/workflows/ci.yml)
[![codecov](https://codecov.io/gh/senresearch/BigRiverPlots.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/senresearch/BigRiverPlots.jl)
[![Docs](https://img.shields.io/badge/docs-dev-blue.svg)](https://senresearch.github.io/BigRiverPlots.jl/dev)
[![Pkg Status](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)


## Description

BigRiverPlots provides a set of plotting recipes for visualizing the output of
dimension reduction and matrix decomposition models. It is the visualization companion
to [BigRiverEssence.jl](https://github.com/senresearch/BigRiverEssence.jl), turning a
fitted model into the standard figures used to read it: scores, loadings, biplots, scree
plots, and more.

> **Why "WolfRiver"?** The name follows the BigRiver Julia package ecosystem, of which
> this package is the plotting component.

![BigRiverPlots example plots](images/banner.svg)

Every plot is built on [RecipesBase](https://github.com/JuliaPlots/RecipesBase.jl), so
the recipes stay dormant until the user loads Plots. They are model-agnostic: each takes
the matrices a model produces — a scores matrix, a loadings matrix, a vector of
variances — rather than the model object itself, so any decomposition that yields those
can be drawn with them.

The package currently provides the following plots:

* Scores plot — the observations in the space of two components
* Loadings plot — the contribution of each variable to one component
* Biplot — the observations and the variable loadings on one canvas
* Loadings heatmap — every variable against every component
* Pairs plot — a grid crossing several components at once
* Scree plot — the variance carried by each component
* VIP plot — the Variable Importance in Projection of a discriminant model
* Sparsity plot — the number of variables each component keeps
* Predicted versus observed plot — the fit of a regression
* JIVE variance plot — the joint, individual, and residual variation of each block
* Mosaic plot — a contingency table drawn as tiles of proportional area

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

