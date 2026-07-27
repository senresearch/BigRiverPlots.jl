#=
plot_jive_variance takes the scaled data blocks and the joint and individual structure of
a fitted JIVE model, so it is not tied to the struct itself. It splits the variation of
each block into three parts, joint, individual, and residual, and stacks them into one
bar per block, so how much of a block is shared with the others, how much is its own, and
how much neither structure catches, all read at a glance.

It serves the JIVE model alone, since JIVE is the model that separates joint from
individual variation. The blocks must be SCALED the way `jive` scales them internally,
row-centered and then Frobenius-normalized so that no block dominates, since the fitted
`J` and `A` are on that scale and the fractions are meaningless against the raw blocks:

	nel = [size(X, 1) * size(X, 2) for X in Xs]; sum_n = sum(nel)
	Dat = [ let Xi = X .- mean(X, dims = 2); Xi ./ (norm(Xi) * sqrt(sum_n)); end
			for X in Xs ]

	jive      plot_jive_variance(Dat, m.J, m.A)

where `Xs` is the vector of raw blocks, `Dat` their scaled form, `m.J` the joint structure
and `m.A` the individual structure. The blocks are needed because the fractions are
measured against the total variation of each block, which the fitted model does not store.

The single table models have no blocks to compare, and the two block correlation models
separate no joint from individual variation, so this plot is JIVE's alone.

Everything else is a plot attribute, so it is passed straight to the plot:

	plot_jive_variance(Dat, m.J, m.A; blocknames = ["genes", "proteins"],
					   title = "Variation Explained")

=#


"""
plot_jive_variance(blocks::Vector{Matrix{Float64}}, joint::Vector{Matrix{Float64}},
				   individual::Vector{Matrix{Float64}}; blocknames::Vector{String} = String[], kwargs...)
Generates a stacked bar plot of the joint, individual, and residual variation of each block of a JIVE model.
## Arguments
- `blocks` is the vector of raw data blocks the model was fitted on, one matrix per
  block, variables (rows) by observations (columns).
- `joint` is the vector of joint structure matrices, `m.J`, one per block.
- `individual` is the vector of individual structure matrices, `m.A`, one per block.
- `blocknames` is a vector of names, one per block, default is `String[]` in which case
  the blocks are named by their index.
"""
function plot_jive_variance(blocks::Vector{Matrix{Float64}}, joint::Vector{Matrix{Float64}},
	individual::Vector{Matrix{Float64}};
	blocknames::Vector{String} = String[], kwargs...)
	# get coordinates ready for plotting
	varJ, varI, varR, names = get_jive_variance_coords(blocks, joint, individual;
		blocknames = blocknames)
	jivevarianceplot(varJ, varI, varR, names; kwargs...)
end


"""
plot_jive_variance!(blocks::Vector{Matrix{Float64}}, joint::Vector{Matrix{Float64}},
					individual::Vector{Matrix{Float64}}; blocknames::Vector{String} = String[], kwargs...)
Adds a stacked bar plot of the joint, individual, and residual variation of each block of a JIVE model to the current plot.
## Arguments
- `blocks` is the vector of raw data blocks the model was fitted on, one matrix per
  block, variables (rows) by observations (columns).
- `joint` is the vector of joint structure matrices, `m.J`, one per block.
- `individual` is the vector of individual structure matrices, `m.A`, one per block.
- `blocknames` is a vector of names, one per block, default is `String[]` in which case
  the blocks are named by their index.
"""
function plot_jive_variance!(blocks::Vector{Matrix{Float64}}, joint::Vector{Matrix{Float64}},
	individual::Vector{Matrix{Float64}};
	blocknames::Vector{String} = String[], kwargs...)
	# get coordinates ready for plotting
	varJ, varI, varR, names = get_jive_variance_coords(blocks, joint, individual;
		blocknames = blocknames)
	jivevarianceplot!(varJ, varI, varR, names; kwargs...)
end
