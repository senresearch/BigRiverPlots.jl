# jive_variance_helpers_tests.jl — unit tests for get_jive_variance_coords.
#
# Self-contained: the blocks and structures are small matrices written by hand here, so
# the test asserts the helper's arithmetic directly, with no fixture, model, or image.

@testset "get_jive_variance_coords" begin

	# one 2×2 block whose variation is split cleanly: the joint and individual structures
	# are chosen so their squared Frobenius norms are known fractions of the block's.
	#
	# block has squared norm 1^2 + 1^2 + 1^2 + 1^2 = 4
	block = [1.0  1.0
		1.0  1.0]

	# joint squared norm = 1  → 1/4 = 0.25
	joint = [1.0  0.0
		0.0  0.0]

	# individual squared norm = 2 → 2/4 = 0.5
	individual = [1.0  0.0
		0.0  1.0]

	varJ, varI, varR, names = get_jive_variance_coords([block], [joint], [individual])

	@test varJ ≈ [0.25]
	@test varI ≈ [0.5]
	@test varR ≈ [0.25]                        # residual is the remainder
	@test varJ .+ varI .+ varR ≈ [1.0]         # the three sum to one
	@test names == ["Block 1"]                 # named by index when none given

	# a second block, all zeros, has no variation to divide by and is left at zero
	zeroblock = zeros(2, 2)
	vJ, vI, vR, _ = get_jive_variance_coords([zeroblock], [zeros(2, 2)], [zeros(2, 2)])
	@test vJ == [0.0]
	@test vI == [0.0]
	@test vR == [0.0]                           # not 1.0 — the zero block short-circuits

	# names pass through when given
	_, _, _, nm = get_jive_variance_coords([block], [joint], [individual];
		blocknames = ["genes"])
	@test nm == ["genes"]

	# the guards
	# mismatched block counts across the three vectors
	@test_throws ErrorException get_jive_variance_coords([block, block], [joint], [individual])
	# a structure whose shape does not match its block
	@test_throws ErrorException get_jive_variance_coords([block], [ones(3, 3)], [individual])
	# a wrong number of blocknames
	@test_throws ErrorException get_jive_variance_coords([block], [joint], [individual];
		blocknames = ["a", "b"])
end
