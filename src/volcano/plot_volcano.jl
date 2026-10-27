"""
    plot_volcano(log2fc, pvalues; genenames=String[], fc_threshold=1.0,
                 pvalue_threshold=0.05, kwargs...)

Generate a volcano plot from log2 fold changes and p-values. Points are classified
as up-regulated, down-regulated, or not significant using the supplied thresholds.
"""
function plot_volcano(log2fc::AbstractVector{<:Real},
	pvalues::AbstractVector{<:Real};
	genenames::AbstractVector{<:AbstractString} = String[],
	fc_threshold::Real = 1.0, pvalue_threshold::Real = 0.05,
	kwargs...)
	x, y, groups, names = get_volcano_coords(log2fc, pvalues;
		genenames = genenames, fc_threshold = fc_threshold,
		pvalue_threshold = pvalue_threshold)
	volcanoplot(x, y, groups, names;
		fc_threshold = fc_threshold, pvalue_threshold = pvalue_threshold, kwargs...)
end

"""
    plot_volcano!(log2fc, pvalues; genenames=String[], fc_threshold=1.0,
                  pvalue_threshold=0.05, kwargs...)

Add a volcano plot from log2 fold changes and p-values to the current plot.
"""
function plot_volcano!(log2fc::AbstractVector{<:Real},
	pvalues::AbstractVector{<:Real};
	genenames::AbstractVector{<:AbstractString} = String[],
	fc_threshold::Real = 1.0, pvalue_threshold::Real = 0.05,
	kwargs...)
	x, y, groups, names = get_volcano_coords(log2fc, pvalues;
		genenames = genenames, fc_threshold = fc_threshold,
		pvalue_threshold = pvalue_threshold)
	volcanoplot!(x, y, groups, names;
		fc_threshold = fc_threshold, pvalue_threshold = pvalue_threshold, kwargs...)
end
