"""
plot_confidence((x::Vector{<:AbstractFloat},
	y ::Vector{<:String},
	ε ::Vector;
	kwargs...)

Generates a confidence plot.

## Arguments
- `x` contains estimated values.
- `y` is a vector where each element correponds the labels of each estimates included in `x`.  
- `ε` vector contains the variations relative to each x-value estimates in the confidence interval. 
	If the variation in not symmetrical, `ε` should be a 2-tuple of vector, where the first vector 
	corresponds to the left variation and the second to the right to the x-estimates.

"""
function plot_confidence(x::Vector{<:AbstractFloat},
	y::Vector{<:String},
	ε::Vector;
	kwargs...)

	confidenceplot(x, y, ε; kwargs...)

end

function plot_confidence!(x::Vector{<:AbstractFloat},
	y::Vector{<:String},
	ε::Vector;
	kwargs...)

	confidenceplot!(x, y, ε; kwargs...)

end
