#=
List of the jive variance helpers functions
- get_jive_variance_coords
	Returns the fraction of each data block's variation that is joint, individual, and
	residual, ready for plotting as stacked bars.

=#


"""
get_jive_variance_coords(blocks::Vector{Matrix{Float64}}, joint::Vector{Matrix{Float64}},
						 individual::Vector{Matrix{Float64}};
						 blocknames::Vector{String} = String[]) =>

Returns the fraction of each data block's variation that is joint, individual, and
residual, ready for plotting as stacked bars.

## Arguments
- `blocks` is the vector of raw data blocks the JIVE model was fitted on, one matrix per
  block, variables (rows) by observations (columns). They are needed because the
  fractions are measured against the total variation of each block.
- `joint` is the vector of joint structure matrices of the fitted model, `m.J`, one per
  block and the same shape as the block.
- `individual` is the vector of individual structure matrices of the fitted model,
  `m.A`, one per block and the same shape as the block.
- `blocknames` is a vector of names, one per block, default is `String[]` for no names,
  in which case the blocks are named by their index.

## Output
- `varJ` vector contains the fraction of each block explained by the joint structure.
- `varI` vector contains the fraction of each block explained by its individual structure.
- `varR` vector contains the residual fraction, what neither the joint nor the individual
  structure accounts for, so the three sum to one for each block.
- `names` vector contains the names of the blocks.

The fractions are the squared Frobenius norm of a structure over the squared norm of the
block, following the definition of variation explained in JIVE. The residual is one minus
the joint and the individual, so a block whose joint fraction is large is one that shares
much of its variation with the other blocks.

"""
function get_jive_variance_coords(blocks::Vector{Matrix{Float64}},
	joint::Vector{Matrix{Float64}},
	individual::Vector{Matrix{Float64}};
	blocknames::Vector{String} = String[])

	k = length(blocks)

	# check that the three vectors describe the same number of blocks
	if length(joint) != k || length(individual) != k
		error("JIVE Variance Plots should be given the same number of blocks, joint and individual.  Got: $(k), $(length(joint)), $(length(individual))")
	end

	# check that a name was given for every block, when any were given
	if !isempty(blocknames) && length(blocknames) != k
		error("JIVE Variance blocknames should be given one per block.  Got: $(length(blocknames)) for $(k)")
	end

	varJ = zeros(k)
	varI = zeros(k)
	varR = zeros(k)

	for i in 1:k

		# each structure and its block must line up, or the norms compare nothing
		if size(joint[i]) != size(blocks[i]) || size(individual[i]) != size(blocks[i])
			error("JIVE Variance Plots should be given structures matching their block.  Got block $(i): $(size(blocks[i])), joint $(size(joint[i])), individual $(size(individual[i]))")
		end

		total = sum(abs2, blocks[i])

		# a block of all zeros has no variation to divide by, so it is left at zero
		if total == 0
			continue
		end

		# the fraction of a block's variation carried by a structure is the squared
		# Frobenius norm of the structure over that of the block
		varJ[i] = sum(abs2, joint[i]) / total
		varI[i] = sum(abs2, individual[i]) / total

		# the residual is whatever the joint and the individual leave behind
		varR[i] = 1 - varJ[i] - varI[i]
	end

	# the blocks are named by their index when no names were given
	if isempty(blocknames)
		names = ["Block $(i)" for i in 1:k]
	else
		names = blocknames
	end

	return varJ, varI, varR, names
end
