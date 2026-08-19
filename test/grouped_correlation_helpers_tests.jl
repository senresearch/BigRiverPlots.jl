##########################################
# GROUPED CORRELATION HELPERS TESTS      #
##########################################

# The fixture is the one written by test/scripts/generate_grouped_correlation.jl. Its
# expected ordering is derived by hand below, so a change in the sort shows up as a failing
# position rather than as a silently different picture.

X_gc = Helium.readhe(joinpath(@__DIR__, "data", "grouped_correlation_data.he"))

meta_gc = readdlm(joinpath(@__DIR__, "data", "grouped_correlation_meta.tsv"), '\t', String)
names_gc = meta_gc[2:end, 1]
classes_gc = meta_gc[2:end, 2]
subclasses_gc = meta_gc[2:end, 3]

hierarchy_gc = [classes_gc, subclasses_gc]
n_gc = length(names_gc)

@testset "get_grouped_correlation_coords" begin

    z, ordered, lnames, spans = get_grouped_correlation_coords(X_gc, names_gc, hierarchy_gc;
        levelnames = ["Class", "Subclass"])

    ##############
    # The matrix #
    ##############

    @testset "correlation matrix" begin
        @test size(z) == (n_gc, n_gc)
        @test z ≈ z'
        @test all(≈(1.0), diag(z))
        @test all(-1 .<= z .<= 1)

        # the matrix is the correlation of the reordered columns, not of the input order
        @test z ≈ cor(X_gc[:, [findfirst(==(name), names_gc) for name in ordered]])
    end

    ############
    # Ordering #
    ############

    @testset "hierarchical ordering" begin
        @test length(ordered) == n_gc
        @test sort(ordered) == sort(names_gc)

        # "amino acid" is lowercase, so a case sensitive sort would put it last. It comes
        # first, which is what the lowercase in the sort key buys
        @test ordered[1:3] == ["Zar_01", "Zar_02", "Zar_03"]
        @test ordered[4:7] == ["Kbr_01", "Kbr_02", "Kbr_03", "Kbr_04"]
        @test ordered[8:11] == ["Cmo_01", "Cmo_02", "Cmo_03", "Cmo_04"]
        @test ordered[12:14] == ["Bsh_01", "Bsh_02", "Bsh_03"]
        @test ordered[15:19] == ["Mph_01", "Mph_02", "Mph_03", "Mph_04", "Mph_05"]
        @test ordered[20:21] == ["Ysh_01", "Ysh_02"]
        @test ordered[22:25] == ["Ast_01", "Ast_02", "Ast_03", "Ast_04"]

        # the tags run against the hierarchy, so sorting the names alone gives a different
        # answer. Without this the test above would pass on a plain name sort
        @test ordered != sort(names_gc)

        # Lipid arrived in three pieces and comes out in one
        lookup = Dict(name => i for (i, name) in enumerate(names_gc))
        ordered_classes = [classes_gc[lookup[name]] for name in ordered]
        runs = 1 + count(i -> ordered_classes[i] != ordered_classes[i-1], 2:n_gc)
        @test runs == 3
    end

    #########
    # Spans #
    #########

    @testset "class spans" begin
        @test length(spans) == 2

        level1 = spans[1]
        @test length(level1) == 3
        @test [span.label for span in level1] == ["amino acid", "Carbohydrate", "Lipid"]
        @test [span.first for span in level1] == [1, 8, 15]
        @test [span.last for span in level1] == [7, 14, 25]
        @test [span.center for span in level1] == [4.0, 11.0, 20.0]
        @test [span.fraction for span in level1] ≈ [7 / 25, 7 / 25, 11 / 25]
        @test [span.path for span in level1] ==
              [("amino acid",), ("Carbohydrate",), ("Lipid",)]
    end

    @testset "subclass spans" begin
        level2 = spans[2]
        @test length(level2) == 7
        @test [span.label for span in level2] == ["aromatic", "Branched", "Monosaccharide",
                                                  "Shared", "phospholipid", "Shared",
                                                  "Sterol"]
        @test [span.first for span in level2] == [1, 4, 8, 12, 15, 20, 22]
        @test [span.last for span in level2] == [3, 7, 11, 14, 19, 21, 25]

        # "Shared" sits under two different classes and stays two spans, cut by the
        # complete prefix rather than by the label
        shared = [span for span in level2 if span.label == "Shared"]
        @test length(shared) == 2
        @test [span.path for span in shared] ==
              [("Carbohydrate", "Shared"), ("Lipid", "Shared")]
        @test [span.first for span in shared] == [12, 20]
    end

    @testset "span arithmetic" begin
        for level in spans
            # the groups of a level tile the axis exactly once, in order
            @test level[1].first == 1
            @test level[end].last == n_gc
            @test all(level[k].first == level[k-1].last + 1 for k in 2:length(level))

            # every span agrees with itself on where it is and how much it owns
            @test all(span.center == (span.first + span.last) / 2 for span in level)
            @test all(span.fraction ≈ (span.last - span.first + 1) / n_gc for span in level)
            @test sum(span.fraction for span in level) ≈ 1.0

            # a nested level is a refinement of the one above it, never a recut
            @test all(span.last <= n_gc for span in level)
        end

        # each class boundary is also a subclass boundary, since a class can only end where
        # one of its subclasses ends
        @test issubset(Set(span.last for span in spans[1]),
                       Set(span.last for span in spans[2]))

        # the deeper level is at least as fine as the shallower one
        @test length(spans[2]) >= length(spans[1])
    end

    ###############
    # Level names #
    ###############

    @testset "level names" begin
        @test lnames == ["Class", "Subclass"]

        _, _, defaults, _ = get_grouped_correlation_coords(X_gc, names_gc, hierarchy_gc)
        @test defaults == ["Level 1", "Level 2"]

        _, _, single, one_level = get_grouped_correlation_coords(X_gc, names_gc,
            [classes_gc]; levelnames = ["Class"])
        @test single == ["Class"]
        @test length(one_level) == 1

        # symbols and other non-strings are accepted and stringified
        _, _, syms, _ = get_grouped_correlation_coords(X_gc, names_gc, hierarchy_gc;
            levelnames = [:Class, :Subclass])
        @test syms == ["Class", "Subclass"]
    end

    ####################
    # Input tolerance  #
    ####################

    @testset "input types" begin
        # integer data is accepted, since the signature takes any real matrix
        counts = [1 4 9; 2 3 7; 5 1 2; 4 6 3]
        z_int, ordered_int, _, spans_int = get_grouped_correlation_coords(counts,
            ["c", "a", "b"], [["g2", "g1", "g1"]])

        @test eltype(z_int) == Float64
        @test ordered_int == ["a", "b", "c"]
        @test [span.label for span in spans_int[1]] == ["g1", "g2"]
        @test [span.fraction for span in spans_int[1]] ≈ [2 / 3, 1 / 3]

        # names given as symbols are stringified too
        _, ordered_sym, _, _ = get_grouped_correlation_coords(counts,
            [:c, :a, :b], [["g2", "g1", "g1"]])
        @test ordered_sym == ["a", "b", "c"]

        # a deeper hierarchy keeps nesting, with no special case at three levels
        deep = [["B", "B", "A", "A"], ["y", "x", "q", "q"], ["2", "1", "2", "1"]]
        _, ordered_deep, _, spans_deep = get_grouped_correlation_coords(
            Float64.([1 2 3 4; 4 3 2 1; 2 5 1 3; 3 1 4 2]),
            ["w", "x", "y", "z"], deep)

        @test length(spans_deep) == 3
        @test [span.label for span in spans_deep[1]] == ["A", "A"] ||
              [span.label for span in spans_deep[1]] == ["A", "B"]
        @test spans_deep[1][1].label == "A"
        @test length(spans_deep[3]) >= length(spans_deep[2])
        @test ordered_deep[1] in ["y", "z"]
    end

    ##########
    # Errors #
    ##########

    @testset "errors" begin
        good = Float64.([1 2 3; 3 1 2; 2 3 1; 4 1 5])
        gnames = ["a", "b", "c"]
        ghier = [["A", "A", "B"]]

        # too little data to correlate
        @test_throws ErrorException get_grouped_correlation_coords(
            reshape([1.0, 2.0, 3.0], 1, 3), gnames, ghier)
        @test_throws ErrorException get_grouped_correlation_coords(
            reshape([1.0, 2.0, 3.0, 4.0], 4, 1), ["a"], [["A"]])

        # one name per variable, one classification per variable
        @test_throws ErrorException get_grouped_correlation_coords(good, ["a", "b"], ghier)
        @test_throws ErrorException get_grouped_correlation_coords(good, gnames,
            [["A", "A"]])
        @test_throws ErrorException get_grouped_correlation_coords(good, gnames,
            [["A", "A", "B"], ["x", "y"]])

        # at least one level, and one name per level if names are given at all
        @test_throws ErrorException get_grouped_correlation_coords(good, gnames,
            Vector{Vector{String}}())
        @test_throws ErrorException get_grouped_correlation_coords(good, gnames, ghier;
            levelnames = ["Class", "Subclass"])

        # missing labels cannot be ordered
        @test_throws ErrorException get_grouped_correlation_coords(good,
            ["a", missing, "c"], ghier)
        @test_throws ErrorException get_grouped_correlation_coords(good, gnames,
            [["A", missing, "B"]])

        # a non-finite entry would spread through the correlation matrix
        @test_throws ErrorException get_grouped_correlation_coords(
            Float64.([1 2 3; 3 1 2; 2 3 1; 4 1 Inf]), gnames, ghier)
        @test_throws ErrorException get_grouped_correlation_coords(
            Float64.([1 2 3; 3 1 2; 2 3 1; 4 1 NaN]), gnames, ghier)

        # a constant column has no defined correlation, and the message names it
        constant = Float64.([1 2 5; 3 1 5; 2 3 5; 4 1 5])
        @test_throws ErrorException get_grouped_correlation_coords(constant, gnames, ghier)

        err = try
            get_grouped_correlation_coords(constant, gnames, ghier)
            ""
        catch caught
            sprint(showerror, caught)
        end
        @test occursin("c", err)
        @test occursin("constant", lowercase(err))
    end
end

##########################################
# The table method                       #
##########################################

@testset "get_grouped_correlation_coords from tables" begin

    data_gc = DataFrame(X_gc, names_gc)
    metadata_gc = DataFrame(name = names_gc, class = classes_gc, subclass = subclasses_gc)

    z_ref, ordered_ref, _, spans_ref = get_grouped_correlation_coords(X_gc, names_gc,
        hierarchy_gc; levelnames = ["name", "class"])

    @testset "matches the matrix method" begin
        z, ordered, lnames, spans = get_grouped_correlation_coords(data_gc, metadata_gc;
            variable_col = :name, group_cols = [:class, :subclass])

        @test z ≈ z_ref
        @test ordered == ordered_ref
        @test length(spans) == 2
        @test [span.first for span in spans[1]] == [span.first for span in spans_ref[1]]

        # the level names come from the classification columns
        @test lnames == ["class", "subclass"]
    end

    @testset "selection and order independence" begin
        # extra columns in the data are ignored, and the data columns need not be in the
        # metadata's order
        shuffled_cols = data_gc[!, shuffle(StableRNG(11), 1:n_gc)]
        shuffled_cols.batch = repeat(["a", "b"], outer = div(size(X_gc, 1), 2))
        shuffled_cols.subject_id = 1:size(X_gc, 1)

        z, ordered, _, _ = get_grouped_correlation_coords(shuffled_cols, metadata_gc;
            variable_col = :name, group_cols = [:class, :subclass])

        @test z ≈ z_ref
        @test ordered == ordered_ref

        # the metadata rows need not be in any order either
        shuffled_meta = metadata_gc[shuffle(StableRNG(12), 1:n_gc), :]
        z2, ordered2, _, _ = get_grouped_correlation_coords(data_gc, shuffled_meta;
            variable_col = :name, group_cols = [:class, :subclass])

        @test z2 ≈ z_ref
        @test ordered2 == ordered_ref

        # a subset of the variables gives the correlation of just that subset
        subset = metadata_gc[metadata_gc.class .== "Lipid", :]
        z3, ordered3, _, spans3 = get_grouped_correlation_coords(data_gc, subset;
            variable_col = :name, group_cols = [:class, :subclass])

        @test size(z3) == (nrow(subset), nrow(subset))
        @test length(spans3[1]) == 1
        @test spans3[1][1].fraction ≈ 1.0
        @test length(spans3[2]) == 3
        @test issubset(Set(ordered3), Set(ordered_ref))
    end

    @testset "classes alone" begin
        z, _, lnames, spans = get_grouped_correlation_coords(data_gc, metadata_gc;
            variable_col = :name, group_cols = [:class])

        @test lnames == ["class"]
        @test length(spans) == 1
        @test [span.label for span in spans[1]] == ["amino acid", "Carbohydrate", "Lipid"]
        @test sum(span.fraction for span in spans[1]) ≈ 1.0
    end

    @testset "errors" begin
        # the identifier and classification columns have to be there
        @test_throws ErrorException get_grouped_correlation_coords(data_gc, metadata_gc;
            variable_col = :missing_col, group_cols = [:class])
        @test_throws ErrorException get_grouped_correlation_coords(data_gc, metadata_gc;
            variable_col = :name, group_cols = [:class, :not_a_column])
        @test_throws ErrorException get_grouped_correlation_coords(data_gc, metadata_gc;
            variable_col = :name, group_cols = Symbol[])

        # at least two variables to correlate
        @test_throws ErrorException get_grouped_correlation_coords(data_gc,
            metadata_gc[1:1, :]; variable_col = :name, group_cols = [:class])

        # each variable once
        duplicated = vcat(metadata_gc, metadata_gc[1:1, :])
        @test_throws ErrorException get_grouped_correlation_coords(data_gc, duplicated;
            variable_col = :name, group_cols = [:class])

        # every identifier has to name a column of the data, and the message says which
        unknown = copy(metadata_gc)
        unknown[1, :name] = "not_a_variable"
        @test_throws ErrorException get_grouped_correlation_coords(data_gc, unknown;
            variable_col = :name, group_cols = [:class])

        err = try
            get_grouped_correlation_coords(data_gc, unknown;
                variable_col = :name, group_cols = [:class])
            ""
        catch caught
            sprint(showerror, caught)
        end
        @test occursin("not_a_variable", err)

        # missing labels
        holes = allowmissing(copy(metadata_gc))
        holes[2, :subclass] = missing
        @test_throws ErrorException get_grouped_correlation_coords(data_gc, holes;
            variable_col = :name, group_cols = [:class, :subclass])

        # a non-numeric variable column
        texty = copy(data_gc)
        texty[!, names_gc[1]] = fill("x", size(X_gc, 1))
        @test_throws ErrorException get_grouped_correlation_coords(texty, metadata_gc;
            variable_col = :name, group_cols = [:class])

        # a variable column carrying missings
        holey = allowmissing(copy(data_gc))
        holey[1, names_gc[1]] = missing
        @test_throws ErrorException get_grouped_correlation_coords(holey, metadata_gc;
            variable_col = :name, group_cols = [:class])
    end
end