# sparsity_helpers_tests.jl — unit tests for get_sparsity_coords.

@testset "get_sparsity_coords" begin

	# 5 variables, 3 components, with a known number of nonzeros per column:
	# col 1 has 3 nonzeros, col 2 has 2, col 3 has 4
	loadings = [1.0  0.0  0.5
		0.0  2.0  0.3
		0.7  0.0  0.0
		0.0  1.5  0.9
		0.4  0.0  0.2]

	# every component
	x, y, names = get_sparsity_coords(loadings)
	@test x == [1, 2, 3]
	@test y == [3.0, 2.0, 4.0]              # counts per component
	@test names == ["1", "2", "3"]

	# an explicit set of components
	x, y, names = get_sparsity_coords(loadings; comps = [1, 3])
	@test y == [3.0, 4.0]
	@test names == ["1", "3"]

	# the leading components
	x, y, names = get_sparsity_coords(loadings; ncomp = 2)
	@test y == [3.0, 2.0]

	# the fraction rather than the count (p = 5)
	x, y, names = get_sparsity_coords(loadings; asfraction = true)
	@test y == [3.0/5, 2.0/5, 4.0/5]

	# names carry through
	cn = ["C1", "C2", "C3"]
	x, y, names = get_sparsity_coords(loadings; comps = [2, 3], compnames = cn)
	@test names == ["C2", "C3"]

	# the guards
	@test_throws ErrorException get_sparsity_coords(loadings; comps = [1, 9])
	@test_throws ErrorException get_sparsity_coords(loadings; compnames = ["a", "b"])

end
