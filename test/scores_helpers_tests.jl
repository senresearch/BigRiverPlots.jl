# scores_helpers_tests.jl — unit tests for get_scores_coords.
#
# These are self-contained: the inputs are small matrices written by hand here, so the
# test asserts the helper's arithmetic directly, with no fixture, no model, and no image.

@testset "get_scores_coords" begin

	# a 3-observation, 4-component matrix, laid out so each entry is recognisable
	scores = [11.0 12.0 13.0 14.0
		21.0 22.0 23.0 24.0
		31.0 32.0 33.0 34.0]

	############################
	# the default two columns  #
	############################

	x, y = get_scores_coords(scores)
	@test x == [11.0, 21.0, 31.0]         # component 1
	@test y == [12.0, 22.0, 32.0]         # component 2

	############################
	# a chosen pair            #
	############################

	x, y = get_scores_coords(scores; comps = (1, 4))
	@test x == [11.0, 21.0, 31.0]         # component 1
	@test y == [14.0, 24.0, 34.0]         # component 4

	x, y = get_scores_coords(scores; comps = (3, 2))
	@test x == [13.0, 23.0, 33.0]         # component 3
	@test y == [12.0, 22.0, 32.0]         # component 2

	############################
	# the guard on the range   #
	############################

	@test_throws ErrorException get_scores_coords(scores; comps = (1, 9))
	@test_throws ErrorException get_scores_coords(scores; comps = (0, 2))
	@test_throws ErrorException get_scores_coords(scores; comps = (5, 1))

end
