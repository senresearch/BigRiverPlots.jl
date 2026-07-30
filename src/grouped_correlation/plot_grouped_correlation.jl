#=
plot_grouped_correlation takes observations by variables and a classification
hierarchy, so it is not tied to any one model or metadata vocabulary. It
orders the variables broadest class first, then every nested class, then variable
name, and draws the correlation of the ordered columns.

For a DataFrame, metadata chooses the variable columns and supplies the hierarchy:

	plot_grouped_correlation(data, metadata;
		variable_col = :VariableID,
		group_cols = [:SuperClassID, :SubClassID])

For a matrix, the same information is passed directly:

	plot_grouped_correlation(X, names, [classes, subclasses];
		levelnames = ["Class", "Subclass"])

One classification vector gives a class-only plot. Additional vectors continue the
hierarchy to subclass, sub-subclass, and beyond. Every level is shown by boundaries and
separate label lanes, with the broadest level outermost. The percentage in each label
shows how much of the axis belongs to the group.

Everything else is a plot attribute, so it is passed straight to the plot:

	plot_grouped_correlation(data, metadata;
		variable_col = :VariableID,
		group_cols = [:ClassID, :SubClassID],
		c = :RdBu, clim = (-1, 1),
		boundarycolor = :grey, boundarywidth = 1.0,
		title = "Grouped correlations")

=#


"""
plot_grouped_correlation(data::AbstractMatrix{<:Real},
							variable_names::AbstractVector,
							hierarchy::AbstractVector{<:AbstractVector};
							levelnames::AbstractVector = String[], kwargs...)

Generates a hierarchically ordered grouped correlation heatmap.

## Arguments
- `data` is the data matrix, observations (rows) by variables (columns).
- `variable_names` contains one name per variable.
- `hierarchy` is a vector of classification vectors, broadest class first and one
  value per variable at every level.
- `levelnames` contains one display name per hierarchy level, default is
  `String[]`.

"""
function plot_grouped_correlation(data::AbstractMatrix{<:Real},
	variable_names::AbstractVector,
	hierarchy::AbstractVector{<:AbstractVector};
	levelnames::AbstractVector = String[], kwargs...)

	z, names, lnames, spans = get_grouped_correlation_coords(data,
		variable_names, hierarchy; levelnames = levelnames)
	groupedcorrelationplot(z, names, lnames, spans; kwargs...)
end


"""
plot_grouped_correlation(data::AbstractDataFrame, metadata::AbstractDataFrame;
							variable_col::Symbol,
							group_cols::Vector{Symbol}, kwargs...)

Generates a hierarchically ordered grouped correlation heatmap from a data table and
a variable metadata table.

## Arguments
- `data` is the data table, observations (rows) by variables (columns). Additional
  columns are ignored.
- `metadata` contains one row per variable to draw.
- `variable_col` names the metadata column whose values match variable columns in
  `data`.
- `group_cols` lists classification columns broadest first. One column gives classes
  alone; further columns give subclasses and deeper levels.

"""
function plot_grouped_correlation(data::AbstractDataFrame,
	metadata::AbstractDataFrame;
	variable_col::Symbol,
	group_cols::Vector{Symbol}, kwargs...)

	z, names, lnames, spans = get_grouped_correlation_coords(data, metadata;
		variable_col = variable_col, group_cols = group_cols)
	groupedcorrelationplot(z, names, lnames, spans; kwargs...)
end


"""
plot_grouped_correlation!(data, args...; kwargs...)

Adds a hierarchically ordered grouped correlation heatmap to the current plot.

"""
function plot_grouped_correlation!(data::AbstractMatrix{<:Real},
	variable_names::AbstractVector,
	hierarchy::AbstractVector{<:AbstractVector};
	levelnames::AbstractVector = String[], kwargs...)

	z, names, lnames, spans = get_grouped_correlation_coords(data,
		variable_names, hierarchy; levelnames = levelnames)
	groupedcorrelationplot!(z, names, lnames, spans; kwargs...)
end


function plot_grouped_correlation!(data::AbstractDataFrame,
	metadata::AbstractDataFrame;
	variable_col::Symbol,
	group_cols::Vector{Symbol}, kwargs...)

	z, names, lnames, spans = get_grouped_correlation_coords(data, metadata;
		variable_col = variable_col, group_cols = group_cols)
	groupedcorrelationplot!(z, names, lnames, spans; kwargs...)
end
