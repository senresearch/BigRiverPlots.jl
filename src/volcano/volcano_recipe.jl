##################
# VOLCANO PLOT  #
##################

"""
	Recipe for volcano plots.
"""

@userplot VolcanoPlot

@recipe function f(h::VolcanoPlot;
	fc_threshold = 1.0,
	pvalue_threshold = 0.05,
	upcolor = :red,
	downcolor = :blue,
	nonsignificantcolor = :gray,
	show_labels = false)

	if length(h.args) != 4 ||
	   any(arg -> !(arg isa AbstractVector), h.args)
		error("Volcano plots should be given four vectors: fold changes, transformed p-values, groups, and names.  Got: $(typeof(h.args))")
	end

	x, y, groups, names = h.args
	if length(x) != length(y) || length(groups) != length(x) || length(names) != length(x)
		error("Volcano plot vectors should have equal lengths.  Got: $(length(x)), $(length(y)), $(length(groups)), $(length(names))")
	end
	if !isfinite(fc_threshold) || fc_threshold < 0
		error("Volcano plot fold-change threshold should be finite and nonnegative.  Got: $(fc_threshold)")
	end
	if !isfinite(pvalue_threshold) || !(0 < pvalue_threshold <= 1)
		error("Volcano plot p-value threshold should be finite and in (0, 1].  Got: $(pvalue_threshold)")
	end

	xlabel --> "log2 fold change"
	ylabel --> "-log10(p-value)"

	guidefontsize --> 15
	fontfamily --> "Helvetica"
	size --> (650, 550)

	legend --> true
	grid --> :both
	gridwidth --> 0.7
	gridalpha --> 0.2
	framestyle --> :box

	groups_to_plot = [
		("Not significant", nonsignificantcolor),
		("Up-regulated", upcolor),
		("Down-regulated", downcolor),
	]

	for (group, color) in groups_to_plot
		idx = findall(==(group), groups)
		isempty(idx) && continue

		@series begin
			seriestype := :scatter
			markercolor := color
			markerstrokecolor := color
			markersize --> 4
			markeralpha --> 0.75
			label := group
			if show_labels && any(i -> !isempty(names[i]), idx)
				series_annotations := names[idx]
			end
			x[idx], y[idx]
		end
	end

	@series begin
		seriestype := :vline
		linecolor := :black
		linestyle := :dash
		linewidth --> 1
		label := ""
		primary := false
		[-fc_threshold, fc_threshold]
	end

	@series begin
		seriestype := :hline
		linecolor := :black
		linestyle := :dash
		linewidth --> 1
		label := ""
		primary := false
		[-log10(Float64(pvalue_threshold))]
	end
end
