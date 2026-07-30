# explore_grouped_correlation.jl — informal check of the grouped correlation recipe
#
# Run from the BigRiverPlots package root with the project active:
#   julia --project=. explore_grouped_correlation.jl
#
# The script displays each plot, saves PNG copies in grouped_correlation_examples,
# and prints ordering and self-consistency checks without using the Test framework.

using Plots
using BigRiverPlots
using DataFrames
using Random
using Statistics
using LinearAlgebra

Random.seed!(20260729)

###########################################################################
# The data                                                                #
###########################################################################
# The simulated variables have a nested correlation structure: variables in the same
# class share one latent signal, while variables in the same subclass share another.
# The resulting heatmap should contain subclass blocks nested inside broader class
# blocks.
#
# The specification is deliberately awkward:
#   1. classes are not supplied in alphabetical order,
#   2. rows belonging to the same class are separated in the specification,
#   3. variable names count backwards inside each subclass.
#
# The helper should correct all three before calculating the correlation matrix.
###########################################################################

n = 120

spec = [
    ("Group Gamma", "Gamma subgroup two", 8),
    ("Group Alpha", "Alpha subgroup two", 7),
    ("Group Beta", "Beta subgroup one", 6),
    ("Group Gamma", "Gamma subgroup one", 7),
    ("Group Alpha", "Alpha subgroup one", 6),
    ("Group Beta", "Beta subgroup two", 5),
]

p = sum(group[3] for group in spec)

# one broad signal per class
classlatent = Dict(
    class => randn(n)
    for class in unique(group[1] for group in spec)
)

columns = Vector{Vector{Float64}}()
classes = String[]
subclasses = String[]
varnames = String[]

for (class, subclass, number) in spec
    sublatent = randn(n)

    for j in 1:number
        # the class signal is broad, the subclass signal is stronger, and the final
        # term gives every variable some independent variation
        push!(
            columns,
            0.75 .* classlatent[class] .+
            1.00 .* sublatent .+
            0.55 .* randn(n),
        )
        push!(classes, class)
        push!(subclasses, subclass)

        # count down so the generated order differs from alphabetical order
        prefix = replace(lowercase(subclass), " " => "_")
        push!(varnames, "$(prefix)_$(lpad(number - j + 1, 2, "0"))")
    end
end

X = reduce(hcat, columns)

println("data: $(n) observations by $(p) variables")
println("classes supplied in this order: ", join(unique(classes), ", "))
println()

###########################################################################
# The hierarchical ordering                                               #
###########################################################################

Z, ordered_names, levelnames, spans = get_grouped_correlation_coords(
    X,
    varnames,
    [classes, subclasses];
    levelnames = ["Class", "Subclass"],
)

# recover the original column index of every ordered variable
name_to_index = Dict(name => index for (index, name) in enumerate(varnames))
perm = [name_to_index[name] for name in ordered_names]

println("order after sorting:")
for (position, index) in enumerate(perm)
    println(
        "  ",
        lpad(position, 3),
        "  ",
        rpad(classes[index], 14),
        rpad(subclasses[index], 23),
        varnames[index],
    )
end
println()

ordered_keys = [
    (
        lowercase(classes[index]),
        lowercase(subclasses[index]),
        lowercase(varnames[index]),
    )
    for index in perm
]

println("sorted at every level      : ", issorted(ordered_keys) ? "yes" : "NO")
println("correlation is symmetric   : ", Z ≈ Z' ? "yes" : "NO")
println("diagonal is one            : ", all(≈(1.0), diag(Z)) ? "yes" : "NO")
println()

###########################################################################
# The hierarchy spans                                                     #
###########################################################################

println("hierarchy levels: ", join(levelnames, ", "))

for (depth, level_spans) in enumerate(spans)
    println("$(levelnames[depth]) spans:")

    for span in level_spans
        percentage = round(100 * span.fraction, digits = 1)
        println(
            "  ",
            rpad(join(span.path, " > "), 40),
            lpad(span.first, 3),
            ":",
            rpad(span.last, 3),
            "  ",
            percentage,
            "%",
        )
    end
end
println()

###########################################################################
# The figures                                                             #
###########################################################################

outdir = joinpath(@__DIR__, "grouped_correlation_examples")
mkpath(outdir)

# one hierarchy level: variables ordered by class, then by variable name
p1 = plot_grouped_correlation(
    X,
    varnames,
    [classes];
    levelnames = ["Class"],
    title = "One level: class only",
    size = (1050, 850),
)
display(p1)
savefig(p1, joinpath(outdir, "grouped_correlation_class.png"))
println("saved grouped_correlation_class.png")

# two hierarchy levels: classes outermost, subclasses immediately inside
p2 = plot_grouped_correlation(
    X,
    varnames,
    [classes, subclasses];
    levelnames = ["Class", "Subclass"],
    title = "Class and subclass",
    size = (1150, 900),
)
display(p2)
savefig(p2, joinpath(outdir, "grouped_correlation_class_subclass.png"))
println("saved grouped_correlation_class_subclass.png")

# the same hierarchy without percentages
p3 = plot_grouped_correlation(
    X,
    varnames,
    [classes, subclasses];
    levelnames = ["Class", "Subclass"],
    showfractions = false,
    title = "Hierarchy labels without percentages",
    size = (1150, 900),
)
display(p3)
savefig(p3, joinpath(outdir, "grouped_correlation_no_percentages.png"))
println("saved grouped_correlation_no_percentages.png")

# hide the outer label lanes; the deepest group names become ordinary ticks
p4 = plot_grouped_correlation(
    X,
    varnames,
    [classes, subclasses];
    levelnames = ["Class", "Subclass"],
    showlabels = false,
    title = "Heatmap boundaries and deepest-level ticks",
    size = (1000, 850),
)
display(p4)
savefig(p4, joinpath(outdir, "grouped_correlation_ticks_only.png"))
println("saved grouped_correlation_ticks_only.png")

# restyle the heatmap and its internal group separators
p5 = plot_grouped_correlation(
    X,
    varnames,
    [classes, subclasses];
    levelnames = ["Class", "Subclass"],
    seriescolor = :PuOr,
    boundarycolor = :black,
    hierarchycolor = "#303030",
    title = "Alternative palette",
    size = (1150, 900),
)
display(p5)
savefig(p5, joinpath(outdir, "grouped_correlation_alternative.png"))
println("saved grouped_correlation_alternative.png")
println()

###########################################################################
# The table method                                                        #
###########################################################################
# The data contain a non-variable sample column. The metadata rows are shuffled, so
# this route checks identifier matching as well as hierarchical ordering.
###########################################################################

data = DataFrame(X, Symbol.(varnames))
insertcols!(data, 1, :SampleID => ["sample_$(i)" for i in 1:n])

metadata = DataFrame(
    VariableID = varnames,
    ClassID = classes,
    SubClassID = subclasses,
)
metadata = metadata[shuffle(1:p), :]

Ztable, table_names, _, _ = get_grouped_correlation_coords(
    data,
    metadata;
    variable_col = :VariableID,
    group_cols = [:ClassID, :SubClassID],
)

println("table order matches matrix : ", table_names == ordered_names ? "yes" : "NO")
println("table matrix matches matrix: ", Ztable ≈ Z ? "yes" : "NO")
println()

p6 = plot_grouped_correlation(
    data,
    metadata;
    variable_col = :VariableID,
    group_cols = [:ClassID, :SubClassID],
    title = "DataFrame and shuffled metadata",
    size = (1150, 900),
)
display(p6)
savefig(p6, joinpath(outdir, "grouped_correlation_table.png"))
println("saved grouped_correlation_table.png")
println()

###########################################################################
# The error paths                                                         #
###########################################################################
# Every call below should fail with a useful validation message.
###########################################################################

constant_data = copy(X)
constant_data[:, 1] .= 1.0

for (description, thunk) in [
    (
        "no hierarchy",
        () -> get_grouped_correlation_coords(X, varnames, AbstractVector[]),
    ),
    (
        "wrong number of names",
        () -> get_grouped_correlation_coords(
            X,
            varnames[1:end-1],
            [classes, subclasses],
        ),
    ),
    (
        "short classification level",
        () -> get_grouped_correlation_coords(
            X,
            varnames,
            [classes, subclasses[1:end-1]],
        ),
    ),
    (
        "constant variable",
        () -> get_grouped_correlation_coords(
            constant_data,
            varnames,
            [classes, subclasses],
        ),
    ),
    (
        "missing metadata identifier",
        () -> get_grouped_correlation_coords(
            data,
            metadata;
            variable_col = :MissingID,
            group_cols = [:ClassID, :SubClassID],
        ),
    ),
]
    try
        thunk()
        println("  ", rpad(description, 32), "NO ERROR — should have failed")
    catch error
        println("  ", rpad(description, 32), sprint(showerror, error))
    end
end

println()
println("plots written to: ", outdir)
