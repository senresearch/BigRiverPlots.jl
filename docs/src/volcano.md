# Volcano plot

The volcano plot displays log2 fold changes against `-log10(p-value)`. By
default, results with an absolute log2 fold change of at least `1` and a
p-value at most `0.05` are highlighted as up- or down-regulated.

```julia
using BigRiverPlots
using Plots

log2fc = [-2.1, -0.4, 0.2, 1.7]
pvalues = [0.003, 0.4, 0.08, 0.01]
genenames = ["gene A", "gene B", "gene C", "gene D"]

plot_volcano(log2fc, pvalues; genenames = genenames)
```

Set `show_labels = true` to annotate points with supplied gene names. The
fold-change and p-value cutoffs can be changed with `fc_threshold` and
`pvalue_threshold`.

```@docs
plot_volcano
plot_volcano!
get_volcano_coords
```
