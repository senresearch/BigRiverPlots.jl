@testset "volcano plot coordinates" begin
	log2fc = [-2.0, -0.5, 0.0, 0.5, 2.0]
	pvalues = [0.01, 0.01, 0.05, 0.5, 0.001]
	names = ["A", "B", "C", "D", "E"]

	x, y, groups, result_names = get_volcano_coords(log2fc, pvalues; genenames = names)

	@test x == log2fc
	@test y ≈ -log10.(pvalues)
	@test groups == ["Down-regulated", "Not significant", "Not significant",
		"Not significant", "Up-regulated"]
	@test result_names == names
	@test isfinite(last(get_volcano_coords([1.0], [0.0])[2]))
	@test_throws ErrorException get_volcano_coords([1.0], [0.1, 0.2])
	@test_throws ErrorException get_volcano_coords([1.0], [-0.1])
	@test_throws ErrorException get_volcano_coords([1.0], [0.1]; genenames = ["A", "B"])
	@test_throws ErrorException get_volcano_coords([1.0], [0.1]; fc_threshold = -1)
	@test_throws ErrorException get_volcano_coords([1.0], [0.1]; pvalue_threshold = 0)
end
