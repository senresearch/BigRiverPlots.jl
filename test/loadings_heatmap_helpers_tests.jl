# loadings_heatmap_helpers_tests.jl — unit tests for get_loadings_heatmap_coords.
#
# Self-contained: the inputs are small matrices written by hand here, so the test asserts
# the helper's arithmetic directly, with no fixture, model, or image.

@testset "get_loadings_heatmap_coords" begin

	# a 5-variable, 3-component matrix. Row 3 is zero on every component, so nonzero has a
	# row to drop; the magnitudes are spread so ntop-by-peak is unambiguous
	loadings = [ 1.0  0.0  0.5
		 0.2  0.9  0.0
		 0.0  0.0  0.0
		-0.3  0.1  0.8
		 0.4  0.0  0.6]

	############################
	# every component          #
	############################

	z, xnames, ynames = get_loadings_heatmap_coords(loadings)
	@test size(z) == (5, 3)                # nothing dropped
	@test xnames == ["1", "2", "3"]
	@test ynames == ["1", "2", "3", "4", "5"]

	############################
	# a subset of components   #
	############################

	z, xnames, ynames = get_loadings_heatmap_coords(loadings; comps = [1, 3])
	@test size(z) == (5, 2)
	@test xnames == ["1", "3"]
	@test z[:, 1] == [1.0, 0.2, 0.0, -0.3, 0.4]     # component 1
	@test z[:, 2] == [0.5, 0.0, 0.0, 0.8, 0.6]      # component 3

	############################
	# nonzero drops row 3      #
	############################

	z, xnames, ynames = get_loadings_heatmap_coords(loadings; nonzero = true)
	@test size(z) == (4, 3)                # the all-zero row 3 is gone
	@test ynames == ["1", "2", "4", "5"]

	############################
	# ntop by the peak         #
	############################

	# the peak (largest absolute value across the components drawn) is row 1 at 1.0, row 2
	# at 0.9, row 4 at 0.8, row 5 at 0.6, row 3 at 0.0; the top three are rows 1, 2, 4,
	# returned in variable order
	z, xnames, ynames = get_loadings_heatmap_coords(loadings; ntop = 3)
	@test ynames == ["1", "2", "4"]

	############################
	# names carry through      #
	############################

	vn = ["a", "b", "c", "d", "e"]
	cn = ["P1", "P2", "P3"]
	z, xnames, ynames = get_loadings_heatmap_coords(loadings; nonzero = true,
		varnames = vn, compnames = cn)
	@test ynames == ["a", "b", "d", "e"]
	@test xnames == ["P1", "P2", "P3"]

	############################
	# the guards               #
	############################

	@test_throws ErrorException get_loadings_heatmap_coords(loadings; comps = [1, 9])
	@test_throws ErrorException get_loadings_heatmap_coords(loadings; varnames = ["a", "b"])
	@test_throws ErrorException get_loadings_heatmap_coords(loadings; compnames = ["a", "b"])
	@test_throws ErrorException get_loadings_heatmap_coords(zeros(5, 3); nonzero = true)

end
