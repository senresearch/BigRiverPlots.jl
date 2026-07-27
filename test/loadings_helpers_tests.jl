# loadings_helpers_tests.jl — unit tests for get_loadings_coords.
#
# Self-contained: the inputs are small matrices written by hand here, so the test asserts
# the helper's arithmetic directly, with no fixture, model, or image.

@testset "get_loadings_coords" begin

	# a 5-variable, 2-component matrix. Component 1 has two zeros, so nonzero and ntop
	# have something to bite on
	loadings = [ 0.0  1.0
		 0.9  2.0
		 0.0  3.0
		-0.5  4.0
		 0.7  5.0]

	############################
	# the whole column         #
	############################

	x, y, names = get_loadings_coords(loadings; comp = 1)
	@test x == [1, 2, 3, 4, 5]
	@test y == [0.0, 0.9, 0.0, -0.5, 0.7]
	@test names == ["1", "2", "3", "4", "5"]

	############################
	# a chosen component       #
	############################

	x, y, names = get_loadings_coords(loadings; comp = 2)
	@test y == [1.0, 2.0, 3.0, 4.0, 5.0]

	############################
	# nonzero drops the zeros  #
	############################

	x, y, names = get_loadings_coords(loadings; comp = 1, nonzero = true)
	@test y == [0.9, -0.5, 0.7]            # the three nonzero loadings
	@test names == ["2", "4", "5"]         # named by their original index
	@test x == [1, 2, 3]                   # repositioned one to three

	############################
	# ntop keeps the largest   #
	############################

	# by magnitude the order on component 1 is 0.9, 0.7, 0.5, so the top two are rows 2
	# and 5, returned in variable order
	x, y, names = get_loadings_coords(loadings; comp = 1, ntop = 2)
	@test names == ["2", "5"]
	@test y == [0.9, 0.7]

	############################
	# names carry through      #
	############################

	vnames = ["a", "b", "c", "d", "e"]
	x, y, names = get_loadings_coords(loadings; comp = 1, nonzero = true, varnames = vnames)
	@test names == ["b", "d", "e"]

	############################
	# the guards               #
	############################

	@test_throws ErrorException get_loadings_coords(loadings; comp = 9)
	@test_throws ErrorException get_loadings_coords(loadings; comp = 1, varnames = ["a", "b"])

	# a column of all zeros with nonzero on leaves nothing to draw
	@test_throws ErrorException get_loadings_coords(zeros(5, 2); comp = 1, nonzero = true)

end
