# biplot_helpers_tests.jl — unit tests for get_biplot_coords and get_ellipse_coords.
#
# Self-contained: the inputs are small matrices written by hand here, so the tests assert
# the helpers' arithmetic directly, with no fixture, model, or image.

@testset "get_biplot_coords" begin

	# 4 observations, 3 components
	scores = [ 1.0  2.0  0.5
		 3.0  1.0  0.2
		-1.0 -2.0  0.1
		 0.0  1.0 -0.3]

	# 5 variables, 3 components. Row 3 is zero on the first two components, so nonzero has
	# a variable to drop when components (1, 2) are drawn
	loadings = [ 0.8  0.1  0.4
		 0.2  0.9  0.1
		 0.0  0.0  0.7
		-0.5  0.3  0.2
		 0.6  0.4  0.9]

	############################
	# the score columns        #
	############################

	# with a fixed arrowscale the arrows are not rescaled, so the numbers are predictable
	sxy, axy, names = get_biplot_coords(scores, loadings; comps = (1, 2), arrowscale = 1.0)
	@test sxy[:, 1] == [1.0, 3.0, -1.0, 0.0]        # component 1 of the scores
	@test sxy[:, 2] == [2.0, 1.0, -2.0, 1.0]        # component 2 of the scores
	@test size(axy) == (5, 2)                        # one arrow per variable
	@test axy[:, 1] == [0.8, 0.2, 0.0, -0.5, 0.6]   # component 1 of the loadings
	@test names == ["1", "2", "3", "4", "5"]

	############################
	# nonzero drops the arrow  #
	############################

	# on components (1, 2), variable 3 is zero on both, so nonzero drops it
	sxy, axy, names = get_biplot_coords(scores, loadings; comps = (1, 2), nonzero = true,
		arrowscale = 1.0)
	@test size(axy, 1) == 4
	@test names == ["1", "2", "4", "5"]

	############################
	# ntop by the arrow length #
	############################

	# the arrow length on (1,2) is sqrt(x^2+y^2): var1 ~0.81, var2 ~0.92, var4 ~0.58,
	# var5 ~0.72, var3 = 0; the top two are var2 and var1, returned in variable order
	sxy, axy, names = get_biplot_coords(scores, loadings; comps = (1, 2), ntop = 2,
		arrowscale = 1.0)
	@test names == ["1", "2"]

	############################
	# the guards               #
	############################

	@test_throws ErrorException get_biplot_coords(scores, loadings; comps = (1, 9))
	@test_throws ErrorException get_biplot_coords(scores, loadings; varnames = ["a", "b"])
	@test_throws ErrorException get_biplot_coords(scores, zeros(5, 3); comps = (1, 2),
		nonzero = true)

end

@testset "get_ellipse_coords" begin

	# a cloud with a clear spread, so the ellipse has a real shape
	x = [1.0, 2.0, 3.0, 4.0, 5.0, 2.5, 3.5]
	y = [2.0, 2.5, 1.5, 3.0, 2.0, 4.0, 0.5]

	npoints = 50
	ex, ey = get_ellipse_coords(x, y; nstd = 2.0, npoints = npoints)

	# the trace has npoints distinct points plus a repeat of the first, to close the loop
	@test length(ex) == npoints + 1
	@test length(ey) == npoints + 1

	# the loop is closed: the last point repeats the first
	@test ex[end] == ex[1]
	@test ey[end] == ey[1]

	# it is centred on the mean of the cloud. Point i and point i+npoints/2 are exact
	# antipodes now that the trace samples npoints distinct angles, and antipodal points
	# average to the centre for any rotation, since the trace is centre .+ R*(radii.*[cos,
	# sin]) and cos, sin flip sign across pi
	half = npoints ÷ 2
	cx = (ex[1] + ex[1+half]) / 2
	cy = (ey[1] + ey[1+half]) / 2
	@test abs(cx - sum(x) / length(x)) < 1e-8
	@test abs(cy - sum(y) / length(y)) < 1e-8

	# a wider nstd traces a bigger ellipse, so its span exceeds the tighter one's
	ex1, ey1 = get_ellipse_coords(x, y; nstd = 1.0, npoints = npoints)
	ex2, ey2 = get_ellipse_coords(x, y; nstd = 3.0, npoints = npoints)
	@test (maximum(ex2) - minimum(ex2)) > (maximum(ex1) - minimum(ex1))

	############################
	# the guards               #
	############################

	# fewer than three points has no covariance worth tracing
	@test_throws ErrorException get_ellipse_coords([1.0, 2.0], [1.0, 2.0])

	# mismatched lengths
	@test_throws ErrorException get_ellipse_coords([1.0, 2.0, 3.0], [1.0, 2.0])

end
