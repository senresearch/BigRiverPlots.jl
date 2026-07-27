# predict_observations_helpers_tests.jl — unit tests for get_predict_observations_coords.

@testset "get_predict_observations_coords" begin

	# 4 observations, 2 responses
	observed = [1.0  10.0
		2.0  20.0
		3.0  30.0
		4.0  40.0]

	# response 1 predicted with a small error, response 2 predicted exactly
	predicted = [1.1  10.0
		1.9  20.0
		3.2  30.0
		3.8  40.0]

	# response 1
	x, y, line, r2 = get_predict_observations_coords(observed, predicted; resp = 1)
	@test x == [1.0, 2.0, 3.0, 4.0]         # the observed column
	@test y == [1.1, 1.9, 3.2, 3.8]         # the predicted column
	@test line == (minimum([x; y]), maximum([x; y]))    # the diagonal spans both
	@test 0.0 < r2 < 1.0                     # a good but imperfect fit

	# response 2 is predicted exactly, so R squared is one and the points lie on the line
	x, y, line, r2 = get_predict_observations_coords(observed, predicted; resp = 2)
	@test x == y
	@test isapprox(r2, 1.0; atol = 1e-12)

	# the guards
	@test_throws ErrorException get_predict_observations_coords(observed, predicted; resp = 9)
	@test_throws ErrorException get_predict_observations_coords(observed, predicted[1:3, :])

end
