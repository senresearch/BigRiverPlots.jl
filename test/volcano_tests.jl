@testset "volcano plot" begin
	log2fc = [-2.0, -0.5, 0.0, 0.5, 2.0]
	pvalues = [0.01, 0.01, 0.05, 0.5, 0.001]
	names = ["A", "B", "C", "D", "E"]

	plt = plot_volcano(log2fc, pvalues; genenames = names)
	point_series = filter(s -> s[:seriestype] == :scatter, plt.series_list)
	@test length(point_series) == 3
	@test sort(vcat([s[:x] for s in point_series]...)) == log2fc
	@test all(s -> s[:series_annotations] === nothing, point_series)

	# Plots converts :vline and :hline into :straightline series.
	@test count(s -> s[:seriestype] == :straightline, plt.series_list) == 2

	labeled = plot_volcano(log2fc, pvalues; genenames = names, show_labels = true)
	labeled_points = filter(s -> s[:seriestype] == :scatter, labeled.series_list)
	@test all(s -> s[:series_annotations] !== nothing, labeled_points)

	@test_throws ErrorException plot_volcano([1.0], [1.1])
end
