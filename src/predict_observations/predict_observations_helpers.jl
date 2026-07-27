#=
List of the predict observations helpers functions
- get_predict_observations_coords
	Returns the observed and predicted values of one response, ready for plotting one
	against the other, together with the reference line and the coefficient of
	determination.

=#


"""
get_predict_observations_coords(observed::Matrix{Float64}, predicted::Matrix{Float64};
								resp::Int = 1) =>

Returns the observed and predicted values of one response, ready for plotting one
against the other, together with the reference line and the coefficient of
determination.

## Arguments
- `observed` is the matrix of observed responses, observations (rows) by responses
  (columns): the Y a PLS regression was fitted or tested against.
- `predicted` is the matrix of predicted responses of the same shape, as returned by
  `plskern_predict`.
- `resp` is the response column drawn, default is `1`. A PLS regression can predict
  several responses at once, so one is chosen; call the plot again with a different
  `resp` for each.

## Output
- `x` vector contains the observed values of the response.
- `y` vector contains the predicted values of the response.
- `line` tuple contains the two endpoints of the line of perfect prediction, as
  `(lo, hi)`, spanning the range of the values shown so the diagonal reaches corner to
  corner.
- `r2` is the coefficient of determination between observed and predicted, the fraction
  of the variance of the observed accounted for, so a value near one is a close fit.

"""
function get_predict_observations_coords(observed::Matrix{Float64}, predicted::Matrix{Float64};
	resp::Int = 1)

	# check that the two matrices line up
	if size(observed) != size(predicted)
		error("Predict Observations Plots should be given observed and predicted of the same size.  Got: $(size(observed)), $(size(predicted))")
	end

	q = size(observed, 2)

	if resp < 1 || resp > q
		error("Response should be in the range 1:$(q).  Got: $(resp)")
	end

	x = observed[:, resp]
	y = predicted[:, resp]

	##################
	# Reference line #
	##################

	# the line of perfect prediction runs at forty five degrees, so it spans the whole
	# range of both the observed and the predicted, corner to corner
	lo = min(minimum(x), minimum(y))
	hi = max(maximum(x), maximum(y))
	line = (lo, hi)

	####################
	# R squared        #
	####################

	# the fraction of the variance of the observed the predictions account for: one minus
	# the residual sum of squares over the total sum of squares
	ybar = sum(x) / length(x)
	ss_tot = sum((x .- ybar) .^ 2)
	ss_res = sum((x .- y) .^ 2)
	r2 = ss_tot == 0 ? 0.0 : 1 - ss_res / ss_tot

	return x, y, line, r2
end
