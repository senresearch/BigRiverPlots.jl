#=
List of the vip helpers functions
- get_vip_coords
	Returns the VIP scores of one component of a VIP matrix, sorted from the largest to
	the smallest, ready for plotting as horizontal bars, together with the names of the
	variables they belong to.

=#


"""
get_vip_coords(vips::Matrix{Float64}; comp::Int = 0, varnames::Vector{String} = String[],
			   above::Bool = false, ntop::Int = 0) =>

Returns the VIP scores of one component of a VIP matrix, sorted from the largest to the
smallest, ready for plotting as horizontal bars, together with the names of the
variables they belong to.

## Arguments
- `vips` is the matrix of Variable Importance in Projection scores, variables (rows) by
  components (columns), as returned by `vip` on a fitted plsda or splsda. Column `h` is
  the VIP through the first `h` components together, so the last column is the overall
  importance and is the one usually read.
- `comp` is the component whose column is drawn, default is `0` for the last, the
  overall VIP. A VIP is cumulative, so an earlier column reads the importance built up
  to that component alone.
- `varnames` is a vector of names, one per variable, default is `String[]` for no
  names, in which case the variables are named by their index. They are subset and
  sorted along with the scores, which is why they are given here.
- `above` keeps only the variables scoring above one, default is `false`. One is the
  usual threshold for an important variable, since the VIP scores are scaled so that
  their mean square is one, so a score above one is above average.
- `ntop` keeps only the `ntop` variables of largest VIP, default is `0` for all of them.
  This is what a model over many variables needs when the names are wanted, though the
  plot hides the names past a few dozen and shows every bar as a curve regardless.

The scores are always returned sorted from the largest to the smallest. The plot lays
them out as horizontal bars up the y-axis, so over many variables the sorted bars read
as a smooth curve falling away from the threshold, and the count of variables clearing
one is the height at which the curve crosses the line.

## Output
- `x` vector contains the positions of the variables, one to the number kept, in sorted order.
- `y` vector contains the VIP scores, from the largest to the smallest.
- `names` vector contains the names of the variables in the same sorted order, or their
  indices as strings when no `varnames` were given.

"""
function get_vip_coords(vips::Matrix{Float64}; comp::Int = 0,
	varnames::Vector{String} = String[],
	above::Bool = false, ntop::Int = 0)

	ncomp = size(vips, 2)

	# the last component is the overall VIP, the column usually read
	c = comp == 0 ? ncomp : comp

	check_comps(c, ncomp)

	# check that a name was given for every variable, when any were given
	if !isempty(varnames) && length(varnames) != size(vips, 1)
		error("VIP varnames should be given one per variable.  Got: $(length(varnames)) for $(size(vips, 1))")
	end

	v = vips[:, c]

	######################
	# Variables to keep  #
	######################

	idx = collect(1:length(v))

	# keep only the important variables, those scoring above the threshold of one
	if above
		idx = idx[v[idx] .> 1]
	end

	if isempty(idx)
		error("VIP Plots should be given a component with at least one variable to draw.  Got: none above the threshold on component $(c)")
	end

	################
	# Sort by VIP  #
	################

	# always ordered from the largest VIP to the smallest, since the layout is a ranked
	# curve, not a plot in variable order. ntop then takes the head of that ranking
	ord = sortperm(v[idx], rev = true)

	if ntop > 0 && ntop < length(ord)
		ord = ord[1:ntop]
	end

	idx = idx[ord]

	x = collect(1:length(idx))
	y = v[idx]

	# the variables are named by their index when no names were given
	if isempty(varnames)
		names = ["$(i)" for i in idx]
	else
		names = varnames[idx]
	end

	return x, y, names
end
