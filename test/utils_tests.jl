# utils_tests.jl — unit tests for the shared helpers get_levels and check_comps.
#
# Self-contained: every input is written by hand here, so the tests assert the helpers
# directly with no fixture, model, or image.

@testset "get_levels" begin

	# the levels come back in order of first appearance, not sorted
	@test get_levels(["b", "a", "b", "c", "a"]) == ["b", "a", "c"]

	# a single class gives a single level
	@test get_levels(["x", "x", "x"]) == ["x"]

	# an empty group has no levels
	@test get_levels(String[]) == []

	# the labels need not be strings
	@test get_levels([2, 1, 2, 3, 1]) == [2, 1, 3]

end

@testset "check_comps, one component" begin

	# a valid index passes and returns nothing
	@test check_comps(1, 4) === nothing
	@test check_comps(4, 4) === nothing

	# an index off either end throws
	@test_throws ErrorException check_comps(0, 4)
	@test_throws ErrorException check_comps(5, 4)
	@test_throws ErrorException check_comps(-1, 4)

end

@testset "check_comps, a pair" begin

	# a valid pair passes and returns nothing
	@test check_comps((1, 2), 4) === nothing
	@test check_comps((4, 1), 4) === nothing

	# a pair with either index out of range throws
	@test_throws ErrorException check_comps((1, 9), 4)
	@test_throws ErrorException check_comps((0, 2), 4)
	@test_throws ErrorException check_comps((2, 5), 4)

end
