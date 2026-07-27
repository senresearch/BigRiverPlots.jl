# pairs_helpers_tests.jl — unit tests for get_pairs_coords.
#
# Self-contained: the inputs are small matrices written by hand here, so the test asserts
# the helper's arithmetic directly, with no fixture, model, or image.

@testset "get_pairs_coords" begin

	# a 3-observation, 4-component matrix, laid out so each entry is recognisable
	scores = [11.0 12.0 13.0 14.0
		21.0 22.0 23.0 24.0
		31.0 32.0 33.0 34.0]

	############################
	# every component          #
	############################

	z, names = get_pairs_coords(scores)
	@test size(z) == (3, 4)                # nothing dropped
	@test z == scores
	@test names == ["1", "2", "3", "4"]

	############################
	# a subset of components   #
	############################

	z, names = get_pairs_coords(scores; comps = [1, 3])
	@test size(z) == (3, 2)
	@test z[:, 1] == [11.0, 21.0, 31.0]    # component 1
	@test z[:, 2] == [13.0, 23.0, 33.0]    # component 3
	@test names == ["1", "3"]

	############################
	# a non contiguous set     #
	############################

	z, names = get_pairs_coords(scores; comps = [4, 1, 3])
	@test names == ["4", "1", "3"]         # kept in the order given
	@test z[:, 1] == [14.0, 24.0, 34.0]    # component 4 first

	############################
	# names carry through      #
	############################

	cn = ["PC1", "PC2", "PC3", "PC4"]
	z, names = get_pairs_coords(scores; comps = [1, 3], compnames = cn)
	@test names == ["PC1", "PC3"]

	############################
	# the guards               #
	############################

	@test_throws ErrorException get_pairs_coords(scores; comps = [1, 9])
	@test_throws ErrorException get_pairs_coords(scores; comps = [1])         # need two
	@test_throws ErrorException get_pairs_coords(scores; compnames = ["a", "b"])

end
