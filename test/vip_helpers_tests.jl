# vip_helpers_tests.jl — unit tests for get_vip_coords.
#
# Self-contained: the inputs are small matrices written by hand here, so the test asserts
# the helper's arithmetic directly, with no fixture, model, or image.

@testset "get_vip_coords" begin

	# 5 variables, 3 components. The last column is the overall VIP the plot reads by
	# default; the values are chosen so the sort order is unambiguous
	vips = [0.5  0.6  0.7
		1.8  1.9  2.0
		0.9  0.8  0.4
		1.1  1.2  1.3
		0.2  0.3  0.6]

	############################
	# the default overall VIP  #
	############################

	# comp = 0 reads the last column, [0.7, 2.0, 0.4, 1.3, 0.6], sorted high to low is
	# variables 2, 4, 1, 5, 3
	x, y, names = get_vip_coords(vips)
	@test y == [2.0, 1.3, 0.7, 0.6, 0.4]
	@test names == ["2", "4", "1", "5", "3"]
	@test x == [1, 2, 3, 4, 5]

	############################
	# a chosen component       #
	############################

	# comp = 1 reads column 1, [0.5, 1.8, 0.9, 1.1, 0.2], sorted is variables 2, 4, 3, 1, 5
	x, y, names = get_vip_coords(vips; comp = 1)
	@test y == [1.8, 1.1, 0.9, 0.5, 0.2]
	@test names == ["2", "4", "3", "1", "5"]

	############################
	# above the threshold      #
	############################

	# on the overall VIP, only variables 2 (2.0) and 4 (1.3) clear one
	x, y, names = get_vip_coords(vips; above = true)
	@test y == [2.0, 1.3]
	@test names == ["2", "4"]

	############################
	# the top few, ranked      #
	############################

	x, y, names = get_vip_coords(vips; ntop = 3)
	@test names == ["2", "4", "1"]         # the three largest, in rank order
	@test y == [2.0, 1.3, 0.7]

	############################
	# names carry through      #
	############################

	vn = ["g1", "g2", "g3", "g4", "g5"]
	x, y, names = get_vip_coords(vips; ntop = 2, varnames = vn)
	@test names == ["g2", "g4"]

	############################
	# the guards               #
	############################

	@test_throws ErrorException get_vip_coords(vips; comp = 9)
	@test_throws ErrorException get_vip_coords(vips; varnames = ["a", "b"])
	@test_throws ErrorException get_vip_coords(zeros(5, 3); above = true)

end
