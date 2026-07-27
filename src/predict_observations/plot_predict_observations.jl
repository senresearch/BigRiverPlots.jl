#=
plot_predict_observations takes an observed and a predicted matrix, so it is not tied to
any one model, though only the regression model of BigRiverEssence produces a continuous
prediction. It scatters the predicted value of each observation against its observed
value, with the line of perfect prediction at forty five degrees, so how far a point
sits from the line is how far the prediction missed.

The kernel PLS regression is the model this serves. Its `plskern_predict` returns the
predicted responses for a set of observations:

	plskern   plot_predict_observations(Y, plskern_predict(m, X))                 # the training fit
			  plot_predict_observations(Ytest, plskern_predict(m, Xtest))         # a test set

A test set is the honest use: the training fit flatters the model, since the same
observations set the coefficients and are then predicted by them. On a test set the
scatter around the line is the error the model would make on data it has not seen.

The discriminant models predict a class, not a value, so their fit is read from a
confusion of the classes rather than from this plot, and the decompositions predict
nothing.

A regression of several responses is drawn one response at a time, with `resp`:

	plot_predict_observations(Y, plskern_predict(m, X); resp = 2)

Everything else is a plot attribute, so it is passed straight to the plot:

	plot_predict_observations(Y, Yhat; xlabel = "observed yield", title = "PLS fit")

=#


"""
plot_predict_observations(observed::Matrix{Float64}, predicted::Matrix{Float64}; resp::Int = 1, kwargs...)
Generates a predicted versus observed plot of a regression, with the line of perfect prediction and the R squared.
## Arguments
- `observed` is the matrix of observed responses, observations (rows) by responses
  (columns).
- `predicted` is the matrix of predicted responses of the same shape, as returned by
  `plskern_predict`.
- `resp` is the response column drawn, default is `1`. Call again with a different
  `resp` for each response of a multivariate regression.
"""
function plot_predict_observations(observed::Matrix{Float64}, predicted::Matrix{Float64};
	resp::Int = 1, kwargs...)
	# get coordinates ready for plotting
	x, y, line, r2 = get_predict_observations_coords(observed, predicted; resp = resp)
	predictobsplot(x, y, line, r2; kwargs...)
end


"""
plot_predict_observations!(observed::Matrix{Float64}, predicted::Matrix{Float64}; resp::Int = 1, kwargs...)
Adds a predicted versus observed plot of a regression to the current plot.
## Arguments
- `observed` is the matrix of observed responses, observations (rows) by responses
  (columns).
- `predicted` is the matrix of predicted responses of the same shape, as returned by
  `plskern_predict`.
- `resp` is the response column drawn, default is `1`. Call again with a different
  `resp` for each response of a multivariate regression.
"""
function plot_predict_observations!(observed::Matrix{Float64}, predicted::Matrix{Float64};
	resp::Int = 1, kwargs...)
	# get coordinates ready for plotting
	x, y, line, r2 = get_predict_observations_coords(observed, predicted; resp = resp)
	predictobsplot!(x, y, line, r2; kwargs...)
end
