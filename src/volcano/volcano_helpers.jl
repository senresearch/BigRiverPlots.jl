"""
    get_volcano_coords(log2fc, pvalues; genenames=String[],
                       fc_threshold=1.0, pvalue_threshold=0.05)

Prepare log2 fold-change and p-value vectors for a volcano plot. Returns the
fold changes, `-log10` transformed p-values, significance groups, and names.
"""
function get_volcano_coords(log2fc::AbstractVector{<:Real},
	pvalues::AbstractVector{<:Real};
	genenames::AbstractVector{<:AbstractString} = String[],
	fc_threshold::Real = 1.0, pvalue_threshold::Real = 0.05)

	if isempty(log2fc)
		error("Volcano plots should be given at least one result.")
	end
	if length(log2fc) != length(pvalues)
		error("Volcano plots should be given equally sized fold-change and p-value vectors.  Got: $(length(log2fc)), $(length(pvalues))")
	end
	if !isempty(genenames) && length(genenames) != length(log2fc)
		error("Volcano plot gene names should be given one per result.  Got: $(length(genenames)) for $(length(log2fc))")
	end
	if !isfinite(fc_threshold) || fc_threshold < 0
		error("Volcano plot fold-change threshold should be finite and nonnegative.  Got: $(fc_threshold)")
	end
	if !isfinite(pvalue_threshold) || !(0 < pvalue_threshold <= 1)
		error("Volcano plot p-value threshold should be finite and in (0, 1].  Got: $(pvalue_threshold)")
	end
	if any(x -> !isfinite(x), log2fc)
		error("Volcano plot fold changes should all be finite.")
	end
	if any(p -> !isfinite(p) || p < 0 || p > 1, pvalues)
		error("Volcano plot p-values should all be finite and in [0, 1].")
	end

	x = Float64.(log2fc)
	y = -log10.(max.(Float64.(pvalues), floatmin(Float64)))
	groups = [
		p <= pvalue_threshold && fc >= fc_threshold && fc > 0 ? "Up-regulated" :
		p <= pvalue_threshold && fc <= -fc_threshold && fc < 0 ? "Down-regulated" :
		"Not significant"
		for (fc, p) in zip(x, pvalues)
	]
	names = isempty(genenames) ? fill("", length(x)) : String.(genenames)

	return x, y, groups, names
end
