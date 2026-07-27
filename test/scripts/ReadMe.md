# test/scripts — fixture and reference generators

This folder holds the scripts that build the test fixtures for every WolfRiverPlots
recipe. Each `generate_*.jl` fits a model on small, seeded data, saves the plot's input
as a `.he` fixture, and renders a reference image. The tests in `test/` then load those
fixtures, re-render, and compare — they never fit a model or touch these scripts at run
time.

You run these **by hand**, only when you deliberately want to (re)create the fixtures.
`runtests.jl` does *not* run them — it only reads what they produced. Regenerating is a
conscious act, because it overwrites the very files the tests check against.

## What each script produces

A generator writes into two sibling folders inside the `test` folder:

- `test/data/*.he` — the **plot's input data**, saved with [Helium](https://github.com/senresearch/Helium.jl).
  This is what the recipe takes: the scores matrix + group vector, the loadings matrix,
  the per-component variances, the VIP matrix, the observed/predicted matrices, the JIVE
  blocks + joint + individual structure, and so on.
- `test/ref/*_ref.png` — the **reference render**: the plot drawn with its default
  attributes, saved as a PNG. The image tests compare a fresh render against this.

One plot gets its own `.he` file(s) — nothing is shared between plots, even when the
underlying data would be identical. So `scores_input.he` serves the scores plot alone.

## Seeding

Every generator seeds with **`StableRNGs`**, not `Random.seed!`. `StableRNG` promises the
identical random stream across Julia versions, so the fixtures never drift when Julia is
upgraded. Each generator passes its `rng` explicitly to every `randn`/`rand`:

```julia
using StableRNGs
rng = StableRNG(20240721)
X = randn(rng, n, p)
```

`StableRNGs` lives in the test environment only (`[extras]` in `Project.toml`), not in the
package deps.

## How to run

From the package root, with the test environment active:

```julia
# regenerate a single plot's fixtures
julia --project=. test/scripts/generate_scores.jl

# regenerate everything at once
julia --project=. test/scripts/generate_all.jl
```

`generate_all.jl` simply `include`s each `generate_*.jl` in turn. After adding a new
generator, wire it in there.

Then run the suite the normal way — it reads the fixtures you just wrote:

```julia
julia> using Pkg; Pkg.test()
```

## How the fixtures are used

The tests come in two independent kinds:

- **`*_tests.jl`** — the image + attribute tests. These load the `.he` fixture, feed it to
  the recipe, render, and compare the image to `ref/*_ref.png`, plus check the series
  attributes via `plt.series_list`. These depend on the files this folder produces.
- **`*_helpers_tests.jl`** — the helper unit tests. These are **self-contained**: they
  build tiny inputs inline and assert the coordinate helper's arithmetic directly. They
  do **not** touch the fixtures, models, or images, so they're fast and version-proof.

## Image comparison: exact vs tolerance

Clean plots (scores, loadings, pairs, heatmap, scree, vip, jive-variance) render
reproducibly and are compared **exactly** (`img_test == img_ref`).

Annotation-heavy plots (biplot arrows, sparsity count labels, predict-observations R²)
carry text that some backends place non-deterministically run to run, so those use a
**tolerance** comparison instead:

```julia
@test size(img_test) == size(img_ref)
frac_diff = sum(img_test .!= img_ref) / length(img_ref)
@test frac_diff < 0.02
```

If a plot you expected to match exactly starts failing on pixels, confirm the render is
actually non-deterministic before switching — render it twice and compare the two. If
they differ, the jitter is real and the tolerance swap is correct; if they're identical,
the reference is stale and needs regenerating, not a looser threshold.

## Test-environment dependencies

The generators and image tests need these in the `[extras]` and `test` target of
`Project.toml`: `BigRiverEssence`, `Plots`, `Helium`, `StableRNGs`, `FileIO`, and
`ImageIO`. `ImageIO` is the codec `FileIO.load` dispatches to for PNGs — without it,
loading a reference image fails even though `FileIO` is present.

## Adding a new plot

1. Write `generate_<plot>.jl` here: seed with `StableRNG`, fit, save the input as
   `test/data/<plot>_input.he`, render, save `test/ref/<plot>_ref.png`.
2. Add `include("generate_<plot>.jl")` to `generate_all.jl`.
3. Write `test/<plot>_helpers_tests.jl` (inline data) and `test/<plot>_tests.jl`
   (fixture + image + attributes).
4. Add both `include` lines to `test/runtests.jl`.
5. Run the generator once, then `Pkg.test()`.