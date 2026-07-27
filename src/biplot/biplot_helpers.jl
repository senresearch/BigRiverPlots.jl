#=
List of the biplot helpers functions
- get_biplot_coords
	Returns the coordinates of two components of a matrix of scores together with the
	loading arrows of the same two components, ready for plotting.
- get_ellipse_coords
	Returns the points of a confidence ellipse around a cloud of observations.

=#


"""
get_biplot_coords(scores::Matrix{Float64}, loadings::Matrix{Float64};
				  comps::Tuple{Int, Int} = (1, 2), varnames::Vector{String} = String[],
				  nonzero::Bool = false, ntop::Int = 0, arrowscale::Float64 = 0.0) =>

Returns the coordinates of two components of a matrix of scores together with the
loading arrows of the same two components, ready for plotting.

## Arguments
- `scores` is the matrix of scores, observations (rows) by components (columns), which
  places the points.
- `loadings` is the matrix of loadings, variables (rows) by components (columns), which
  points the arrows. It should come from the same fitted model as `scores`.
- `comps` is a tuple naming the two components placed on the x and y axes, default is
  `(1, 2)`.
- `varnames` is a vector of names, one per variable, default is `String[]` for no
  names, in which case the variables are named by their index. They are subset along
  with the arrows, which is why they are given here.
- `nonzero` keeps only the variables whose loading is not zero on at least one of the
  two components drawn, default is `false`. This is what the models with an L1 penalty
  need, since most of their arrows would otherwise be drawn as stubs of length zero
  piled at the origin.
- `ntop` keeps only the `ntop` variables of largest arrow length, default is `0` for
  all of them. This is what the dense models need, since an arrow per variable over
  thousands of them buries the points.
- `arrowscale` is the factor the arrows are scaled by, default is `0.0` to scale them
  automatically. The loadings are unit length, so on the scale of the scores the arrows
  would be invisibly short: they are stretched to about four fifths of the point cloud.
  The scaling is conventional, so the DIRECTIONS and the RELATIVE lengths of the arrows
  carry meaning while the absolute length does not.

## Output
- `sxy` matrix contains the scores of the observations on the two components, in two columns.
- `axy` matrix contains the scaled arrow tips of the variables kept, in two columns.
- `names` vector contains the names of the variables kept, one per row of `axy`.

"""
function get_biplot_coords(scores::Matrix{Float64}, loadings::Matrix{Float64};
	comps::Tuple{Int, Int} = (1, 2),
	varnames::Vector{String} = String[],
	nonzero::Bool = false, ntop::Int = 0,
	arrowscale::Float64 = 0.0)

	check_comps(comps, size(scores, 2))
	check_comps(comps, size(loadings, 2))
	i, j = comps

	# check that a name was given for every variable, when any were given
	if !isempty(varnames) && length(varnames) != size(loadings, 1)
		error("Biplot varnames should be given one per variable.  Got: $(length(varnames)) for $(size(loadings, 1))")
	end

	sxy = scores[:, [i, j]]

	######################
	# Variables to keep  #
	######################

	idx = collect(1:size(loadings, 1))

	# drop the variables the penalty zeroed out on both components, since their arrows
	# have no length and only crowd the origin
	if nonzero
		idx = idx[[loadings[v, i] != 0 || loadings[v, j] != 0 for v in idx]]
	end

	if isempty(idx)
		error("Biplots should be given at least one variable to draw.  Got: none on components $(comps)")
	end

	# rank by the length of the arrow, which is what the reader of a biplot goes by,
	# then put them back in variable order
	if ntop > 0 && ntop < length(idx)
		len = [sqrt(loadings[v, i]^2 + loadings[v, j]^2) for v in idx]
		ord = sortperm(len, rev = true)
		idx = sort(idx[ord[1:ntop]])
	end

	axy = loadings[idx, [i, j]]

	##################
	# Arrow scaling  #
	##################

	s = arrowscale

	# the loadings are unit length, so without a stretch the arrows sit invisible at
	# the origin next to the cloud of points
	if s == 0.0
		srange = maximum(abs, sxy)
		lrange = maximum(abs, axy)
		s = lrange == 0 ? 1.0 : 0.8 * srange / lrange
	end

	axy = s .* axy

	# the variables are named by their index when no names were given
	if isempty(varnames)
		names = ["$(v)" for v in idx]
	else
		names = varnames[idx]
	end

	return sxy, axy, names
end


"""
get_ellipse_coords(x::AbstractVector, y::AbstractVector; nstd::Float64 = 2.5,
				   npoints::Int = 100) =>

Returns the points of a confidence ellipse around a cloud of observations.

## Arguments
- `x` is a vector of the coordinates of the observations on the first component.
- `y` is a vector of the coordinates of the observations on the second component.
- `nstd` is the number of standard deviations the ellipse is drawn at, default is `2.5`.
  A larger value draws a wider ellipse: at 2.5 the ellipse covers most of a class that
  is roughly normal, so a point outside it is worth a look.
- `npoints` is the number of points the ellipse is traced with, default is `100`.

## Output
- `ex` vector contains the coordinates of the ellipse on the first component.
- `ey` vector contains the coordinates of the ellipse on the second component.

The ellipse is the unit circle scaled by `nstd` standard deviations along each of the
principal axes of the covariance of the cloud, then rotated onto those axes and moved
onto its center. It is computed here rather than taken from `covellipse` of StatsPlots,
so that the package needs no dependency beyond RecipesBase and the standard library.

"""
function get_ellipse_coords(x::AbstractVector, y::AbstractVector; nstd::Float64 = 2.5,
	npoints::Int = 100)

	# a covariance needs three points to be worth anything, and two to exist at all
	if length(x) < 3
		error("Ellipses should be given at least three observations.  Got: $(length(x))")
	end

	if length(x) != length(y)
		error("Ellipses should be given vectors of equal length.  Got: $(length(x)), $(length(y))")
	end

	C = cov(hcat(x, y))

	# the eigenvectors give the axes of the cloud and the eigenvalues their variances,
	# so the square roots of the eigenvalues are the radii in standard deviations
	F = eigen(Symmetric(C))

	# a variance is never negative, but a rounding error can leave a tiny one so
	vals = max.(F.values, 0.0)

	# npoints distinct angles around the circle, without repeating the start point at the
	# end, so the trace carries no duplicate and point i and point i+npoints/2 are exact
	# antipodes
	t = range(0, 2 * pi, length = npoints + 1)[1:npoints]
	circle = vcat(cos.(t)', sin.(t)')

	# scale the unit circle onto the radii, then rotate it onto the axes of the cloud
	pts = F.vectors * ((nstd .* sqrt.(vals)) .* circle)

	ex = pts[1, :] .+ mean(x)
	ey = pts[2, :] .+ mean(y)

	# close the loop for drawing: the trace stops one step short of a full turn, so the
	# first point is appended to bring the path back to where it began
	push!(ex, ex[1])
	push!(ey, ey[1])

	return ex, ey
end
