# scree_helpers_tests.jl — unit tests for get_scree_coords.
#
# Self-contained: the inputs are small vectors written by hand here, so the test asserts
# the helper's arithmetic directly, with no fixture, model, or image.

@testset "get_scree_coords" begin

	# a falling sequence of per-component values
	values = [10.0, 6.0, 3.0, 1.5, 0.5]

	############################
	# every component          #
	############################

	x, y, names = get_scree_coords(values)
	@test x == [1, 2, 3, 4, 5]
	@test y == [10.0, 6.0, 3.0, 1.5, 0.5]
	@test names == ["1", "2", "3", "4", "5"]

	############################
	# the leading components   #
	############################

	x, y, names = get_scree_coords(values; ncomp = 3)
	@test x == [1, 2, 3]
	@test y == [10.0, 6.0, 3.0]
	@test names == ["1", "2", "3"]

	############################
	# the cumulative curve     #
	############################

	x, y, names = get_scree_coords(values; cumulative = true)
	@test y == [10.0, 16.0, 19.0, 20.5, 21.0]     # the running total

	# cumulative truncated: the running total is taken over the components kept
	x, y, names = get_scree_coords(values; ncomp = 3, cumulative = true)
	@test y == [10.0, 16.0, 19.0]

	############################
	# names carry through      #
	############################

	cn = ["PC1", "PC2", "PC3", "PC4", "PC5"]
	x, y, names = get_scree_coords(values; ncomp = 2, compnames = cn)
	@test names == ["PC1", "PC2"]

	############################
	# the guard                #
	############################

	@test_throws ErrorException get_scree_coords(values; compnames = ["a", "b"])

end
