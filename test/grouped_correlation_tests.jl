##########################################
# GROUPED CORRELATION PLOT TESTS         #
##########################################

# The recipe puts the heatmap in one series, the boundaries of each level in a pair of
# NaN separated paths, and the group names in a pair of invisible scatter series carrying
# series annotations. Series recipes lose their type tag in the pipeline, so nothing here
# matches on a seriestype that was only asked for by alias — the heatmap, the paths, and
# the scatters are all primitives by the time they land in series_list.

##########################################
# Reading a built plot                   #
##########################################

# a heatmap stores its values as a Surface, which is not always an AbstractMatrix
_gc_zmatrix(series) = series[:z] isa AbstractMatrix ? series[:z] : series[:z].surf

# series annotations arrive as PlotText, whose string sits in the str field
function _gc_annotations(series)
    annotations = series[:series_annotations]
    annotations === nothing && return String[]
    return [entry isa AbstractString ? String(entry) : String(entry.str)
            for entry in annotations.strs]
end

_gc_paths(plt) = [s for s in plt.series_list if s[:seriestype] == :path]

_gc_labelseries(plt) = [s for s in plt.series_list
                        if s[:seriestype] == :scatter && !isempty(_gc_annotations(s))]

_gc_finite(values) = sort(unique(filter(isfinite, values)))

# wrapping breaks a long label across lines, and it breaks inside a word when the word is
# itself longer than the line. Stripping whitespace compares what a label says without
# caring where the breaks landed
_gc_squash(text) = replace(text, r"\s" => "")

@testset "groupedcorrelationplot" begin

    z, ordered, lnames, spans = get_grouped_correlation_coords(X_gc, names_gc,
        hierarchy_gc; levelnames = ["Class", "Subclass"])

    plt = groupedcorrelationplot(z, ordered, lnames, spans)

    ###############
    # The heatmap #
    ###############

    @testset "the heatmap" begin
        heatmaps = [s for s in plt.series_list if s[:seriestype] == :heatmap]
        @test length(heatmaps) == 1

        surface = heatmaps[1]
        @test size(_gc_zmatrix(surface)) == (n_gc, n_gc)
        @test _gc_zmatrix(surface) ≈ z
        @test length(surface[:x]) == n_gc
        @test length(surface[:y]) == n_gc
        @test surface[:x] == collect(1:n_gc)
    end

    ##############
    # Boundaries #
    ##############

    @testset "boundaries" begin
        paths = _gc_paths(plt)

        # a vertical and a horizontal series for each of the two levels
        @test length(paths) == 4

        # every path is segmented, so the cuts do not join up across the plot
        @test all(any(isnan, s[:x]) for s in paths)
        @test all(any(isnan, s[:y]) for s in paths)

        # the boundaries fall half a cell past the last variable of a group, and the edges
        # of the map close the outermost groups
        expected = sort(unique(vcat(0.5, n_gc + 0.5,
                                    [span.last + 0.5 for level in spans
                                     for span in level if span.last < n_gc])))

        @test _gc_finite(vcat([s[:x] for s in paths]...)) ≈ expected
        @test _gc_finite(vcat([s[:y] for s in paths]...)) ≈ expected

        # class boundaries are drawn heavier than subclass boundaries, two series each
        widths = sort([s[:linewidth] for s in paths])
        @test length(unique(widths)) == 2
        @test widths[1] == widths[2]
        @test widths[3] == widths[4]
        @test widths[3] > widths[1]

        # none of them join the legend
        @test all(s[:label] == "" for s in paths)
    end

    @testset "boundaries can be styled" begin
        styled = groupedcorrelationplot(z, ordered, lnames, spans;
            boundarycolor = :black, boundarywidth = 2.0)

        paths = _gc_paths(styled)
        @test length(paths) == 4

        # the deepest level is drawn at the given width and each level above it heavier
        @test minimum(s[:linewidth] for s in paths) == 2.0
        @test maximum(s[:linewidth] for s in paths) > 2.0
    end

    ##########
    # Labels #
    ##########

    @testset "group labels" begin
        labels = _gc_labelseries(plt)

        # one lane along the x axis and one down the y axis, for each of the two levels
        @test length(labels) == 4

        # the label markers are placeholders for the annotations and must not be drawn
        @test all(s[:markeralpha] == 0 for s in labels)
        @test all(s[:markersize] == 0 for s in labels)
        @test all(s[:label] == "" for s in labels)

        texts = vcat([_gc_annotations(s) for s in labels]...)

        # the default wrapping breaks a label across lines, and breaks inside a word when
        # the word outruns the line, so content is checked on the squashed text
        squashed = _gc_squash.(texts)

        # every group of every level is named, twice over, once per axis
        @test length(texts) == 2 * (length(spans[1]) + length(spans[2]))

        # each label carries its share of the axis
        @test all(occursin("%", text) for text in texts)
        @test any(occursin("28.0%", text) for text in squashed)
        @test any(occursin("44.0%", text) for text in squashed)

        # "Shared" appears under two classes, so both are qualified by their full path and
        # neither is left ambiguous. Two levels times two axes is four qualified labels
        @test count(text -> occursin("›", text), texts) == 4
        @test any(text -> occursin("Carbohydrate", text) && occursin("Shared", text),
                  squashed)
        @test any(text -> occursin("Lipid", text) && occursin("Shared", text), squashed)

        # a label that is unique at its level is not qualified
        @test any(text -> occursin("Sterol", text) && !occursin("›", text), squashed)

        # the lanes sit outside the map, the broadest level farthest out
        lane_positions = sort(unique(vcat([s[:y] for s in labels]...,
                                          [s[:x] for s in labels]...)))
        @test any(pos -> pos < 0.5, lane_positions)
    end

    @testset "labels can be turned off" begin
        bare = groupedcorrelationplot(z, ordered, lnames, spans; showlabels = false)

        # no annotation series at all, and the axis falls back to ordinary ticks
        @test isempty(_gc_labelseries(bare))
        @test length(bare.series_list) == 1 + 4

        ticks = bare[1][:xaxis][:ticks]
        @test ticks isa Tuple
        @test length(ticks[1]) == length(spans[end])
        @test ticks[1] ≈ [span.center for span in spans[end]]

        # with the lanes gone the map is no longer padded out to the left
        @test bare[1][:xaxis][:lims][1] == 0.5
    end

    @testset "fractions can be turned off" begin
        plain = groupedcorrelationplot(z, ordered, lnames, spans; showfractions = false)

        texts = vcat([_gc_annotations(s) for s in _gc_labelseries(plain)]...)
        @test !isempty(texts)
        @test all(!occursin("%", text) for text in texts)

        # the path qualification survives, since it is what keeps the names unambiguous
        @test count(text -> occursin("›", text), texts) == 4
        @test any(text -> text == "Sterol", texts)
    end

    @testset "label wrapping" begin
        wrapped = groupedcorrelationplot(z, ordered, lnames, spans; labelwrap = true,
            labelcapacity = 12)
        unwrapped = groupedcorrelationplot(z, ordered, lnames, spans; labelwrap = false)

        wrapped_texts = vcat([_gc_annotations(s) for s in _gc_labelseries(wrapped)]...)
        unwrapped_texts = vcat([_gc_annotations(s) for s in _gc_labelseries(unwrapped)]...)

        # a small capacity forces line breaks into the longer names
        @test any(text -> occursin("\n", text), wrapped_texts)
        @test all(text -> !occursin("\n", text), unwrapped_texts)

        # wrapping only inserts breaks, it does not drop or reorder characters. A break can
        # land inside a word, so the comparison ignores whitespace rather than mapping each
        # newline back to a space
        @test _gc_squash.(wrapped_texts) == _gc_squash.(unwrapped_texts)
    end

    ###################
    # Axis attributes #
    ###################

    @testset "axis attributes" begin
        @test plt[1][:xaxis][:guide] == "Variables grouped by Class / Subclass"
        @test plt[1][:yaxis][:guide] == "Variables grouped by Class / Subclass"

        # the scale is fixed to the full range of a correlation, so a weak block cannot be
        # stretched into looking like a strong one. clims is a subplot attribute, not a
        # series one
        @test plt[1][:clims] == (-1, 1)

        # the label lanes are padded into the frame, and the map itself ends at the cells
        @test plt[1][:xaxis][:lims][1] < 0.5
        @test plt[1][:xaxis][:lims][2] == n_gc + 0.5
        @test plt[1][:yaxis][:lims] == plt[1][:xaxis][:lims]

        # with the lanes shown there are no numeric ticks to collide with them. Plots
        # normalizes a false to nothing, and both mean the same thing
        @test plt[1][:xaxis][:ticks] in (false, nothing)
        @test plt[1][:yaxis][:ticks] in (false, nothing)

        # attributes are defaults, so the caller still wins
        titled = groupedcorrelationplot(z, ordered, lnames, spans;
            title = "Grouped correlations", xlabel = "mine")
        @test titled[1][:title] == "Grouped correlations"
        @test titled[1][:xaxis][:guide] == "mine"
    end

    ####################
    # Level structure  #
    ####################

    @testset "one level" begin
        z1, ordered1, lnames1, spans1 = get_grouped_correlation_coords(X_gc, names_gc,
            [classes_gc]; levelnames = ["Class"])

        single = groupedcorrelationplot(z1, ordered1, lnames1, spans1)

        # one heatmap, one pair of boundary paths, one pair of label lanes
        @test length(single.series_list) == 1 + 2 + 2
        @test length(_gc_paths(single)) == 2
        @test length(_gc_labelseries(single)) == 2

        texts = vcat([_gc_annotations(s) for s in _gc_labelseries(single)]...)
        @test length(texts) == 2 * length(spans1[1])

        # nothing is ambiguous at a single level here, so nothing is path qualified
        @test all(text -> !occursin("›", text), texts)
        @test single[1][:xaxis][:guide] == "Variables grouped by Class"
    end

    @testset "a level with a single group draws no boundaries" begin
        # every variable in one class: the group is closed by the edge of the map, so there
        # is no interior boundary to draw
        one_class = fill("Everything", n_gc)
        z1, ordered1, lnames1, spans1 = get_grouped_correlation_coords(X_gc, names_gc,
            [one_class]; levelnames = ["Class"])

        @test length(spans1[1]) == 1
        @test spans1[1][1].fraction ≈ 1.0

        flat = groupedcorrelationplot(z1, ordered1, lnames1, spans1)
        @test isempty(_gc_paths(flat))
        @test length(flat.series_list) == 1 + 0 + 2
    end

    @testset "three levels" begin
        thirds = [string("g", mod(i, 3)) for i in 1:n_gc]
        z3, ordered3, lnames3, spans3 = get_grouped_correlation_coords(X_gc, names_gc,
            [classes_gc, subclasses_gc, thirds])

        deep = groupedcorrelationplot(z3, ordered3, lnames3, spans3)

        # a pair of boundary paths and a pair of label lanes for each of the three levels
        @test length(_gc_paths(deep)) == 6
        @test length(_gc_labelseries(deep)) == 6

        # the lanes stack outward, so a deeper hierarchy is padded further from the map
        @test deep[1][:xaxis][:lims][1] < plt[1][:xaxis][:lims][1]
    end

    ##########
    # Errors #
    ##########

    @testset "errors" begin
        # the verb takes a matrix and three vectors
        @test_throws ErrorException groupedcorrelationplot(z, ordered)
        @test_throws ErrorException groupedcorrelationplot(z, ordered, lnames)
        @test_throws ErrorException groupedcorrelationplot(z, ordered, lnames, spans, spans)
        @test_throws ErrorException groupedcorrelationplot(ordered, ordered, lnames, spans)

        # the matrix is square and matches its names
        @test_throws ErrorException groupedcorrelationplot(z[:, 1:end-1], ordered, lnames,
            spans)
        @test_throws ErrorException groupedcorrelationplot(z, ordered[1:end-1], lnames,
            spans)

        # one name and one set of spans per level
        @test_throws ErrorException groupedcorrelationplot(z, ordered, ["Class"], spans)
        @test_throws ErrorException groupedcorrelationplot(z, ordered, lnames,
            Vector{Vector{NamedTuple}}())
    end
end

##########################################
# The wrapper                            #
##########################################

@testset "plot_grouped_correlation" begin

    data_gc = DataFrame(X_gc, names_gc)
    metadata_gc = DataFrame(name = names_gc, class = classes_gc, subclass = subclasses_gc)

    @testset "matrix method" begin
        plt = plot_grouped_correlation(X_gc, names_gc, hierarchy_gc;
            levelnames = ["Class", "Subclass"])

        @test length(plt.series_list) == 1 + 4 + 4
        @test plt[1][:xaxis][:guide] == "Variables grouped by Class / Subclass"

        # plot attributes pass straight through the wrapper to the recipe
        styled = plot_grouped_correlation(X_gc, names_gc, hierarchy_gc;
            levelnames = ["Class", "Subclass"], showfractions = false,
            title = "Grouped correlations")

        texts = vcat([_gc_annotations(s) for s in _gc_labelseries(styled)]...)
        @test all(!occursin("%", text) for text in texts)
        @test styled[1][:title] == "Grouped correlations"
    end

    @testset "table method" begin
        plt = plot_grouped_correlation(data_gc, metadata_gc;
            variable_col = :name, group_cols = [:class, :subclass])

        @test length(plt.series_list) == 1 + 4 + 4

        # the level names are taken from the classification columns
        @test plt[1][:xaxis][:guide] == "Variables grouped by class / subclass"

        heatmaps = [s for s in plt.series_list if s[:seriestype] == :heatmap]
        @test _gc_zmatrix(heatmaps[1]) ≈ get_grouped_correlation_coords(X_gc, names_gc,
            hierarchy_gc)[1]
    end

    @testset "adding to a plot" begin
        plot()
        added = plot_grouped_correlation!(X_gc, names_gc, hierarchy_gc)
        @test length(_gc_paths(added)) == 4

        plot()
        added_table = plot_grouped_correlation!(data_gc, metadata_gc;
            variable_col = :name, group_cols = [:class])
        @test length(_gc_paths(added_table)) == 2
    end

    @testset "errors propagate from the helper" begin
        @test_throws ErrorException plot_grouped_correlation(X_gc, names_gc[1:end-1],
            hierarchy_gc)
        @test_throws ErrorException plot_grouped_correlation(X_gc, names_gc,
            Vector{Vector{String}}())
        @test_throws ErrorException plot_grouped_correlation(data_gc, metadata_gc;
            variable_col = :name, group_cols = [:not_a_column])
    end
end

##########################################
# The reference image                    #
##########################################
# One reference, the default figure. The label lanes are drawn as text, and text rendering
# shifts between GR versions, so the comparison is by fraction of differing pixels rather
# than exact. The variants of the figure are covered by the series and annotation checks
# above, which do not need an image to compare against. Regenerate the reference with
# test/scripts/generate_grouped_correlation.jl only when the figure is meant to change.

@testset "grouped correlation reference image" begin

    reference = joinpath(@__DIR__, "ref", "grouped_correlation.png")

    if !isfile(reference)
        @info "no reference image at $(reference), skipping"
    else
        plt = plot_grouped_correlation(X_gc, names_gc, hierarchy_gc;
            levelnames = ["Class", "Subclass"])

        produced = tempname() * ".png"
        savefig(plt, produced)

        want = load(reference)
        got = load(produced)

        @test size(want) == size(got)

        if size(want) == size(got)
            # a couple of percent covers text rendering drift without letting a moved block
            # or a dropped boundary through
            @test count(want .!= got) / length(want) < 0.02
        end
    end
end