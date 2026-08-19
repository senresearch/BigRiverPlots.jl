# generate_grouped_correlation.jl
#
# Builds the grouped correlation fixtures and reference images. Run by hand from the
# package root, never by runtests.jl:
#
#   julia --project=. test/scripts/generate_grouped_correlation.jl
#
# Writes:
#   test/data/grouped_correlation_data.he    the observations by variables matrix
#   test/data/grouped_correlation_meta.tsv   the variable names and their hierarchy
#   test/ref/grouped_correlation.png         the reference image
#
# Rerun only when the figure is meant to change, and inspect the new image before
# committing it.

using Plots
using StableRNGs
using Helium
using DelimitedFiles
using BigRiverPlots

gr()

rng = StableRNG(20260729)

const DATADIR = joinpath(@__DIR__, "..", "data")
const REFDIR = joinpath(@__DIR__, "..", "ref")

mkpath(DATADIR)
mkpath(REFDIR)

##########################################################################
# The specification                                                      #
##########################################################################
# Deliberately awkward in five ways, one per behaviour the helper has to get right:
#
#   1. the classes are not in alphabetical order,
#   2. Lipid arrives in three separate pieces, so contiguity has to be created,
#   3. "amino acid" is lowercase while the others are capitalized, so a case sensitive
#      sort would place it last instead of first,
#   4. the subclass "Shared" appears under both Carbohydrate and Lipid, so spans have to
#      be cut by the complete prefix rather than by the label alone,
#   5. the name tags run against the hierarchy — Sterol is tagged Ast and sorts last,
#      aromatic is tagged Zar and sorts first — so sorting on names alone gives a
#      different answer from sorting through the hierarchy.
#
# Within a subclass the numbers count down, so alphabetical order on the innermost key
# reverses the order the columns were generated in.
##########################################################################

nobs = 150

spec = [("Lipid",        "Sterol",         "Ast", 4),
        ("amino acid",   "aromatic",       "Zar", 3),
        ("Lipid",        "phospholipid",   "Mph", 5),
        ("Carbohydrate", "Shared",         "Bsh", 3),
        ("Lipid",        "Shared",         "Ysh", 2),
        ("amino acid",   "Branched",       "Kbr", 4),
        ("Carbohydrate", "Monosaccharide", "Cmo", 4)]

nvar = sum(row[4] for row in spec)

##########################################################################
# The data                                                               #
##########################################################################
# Nested block structure: one latent signal per class shared by all its subclasses, one
# per subclass, and independent noise. A correct figure shows a warm block per subclass
# sitting inside a warmer than background block per class.
##########################################################################

classlatent = Dict(class => randn(rng, nobs) for class in unique(row[1] for row in spec))

columns = Vector{Vector{Float64}}()
variable_names = String[]
classes = String[]
subclasses = String[]

for (class, subclass, tag, count) in spec
    sublatent = randn(rng, nobs)

    for j in 1:count
        push!(columns, 0.8 .* classlatent[class] .+ sublatent .+ 0.5 .* randn(rng, nobs))
        push!(variable_names, string(tag, "_", lpad(count - j + 1, 2, "0")))
        push!(classes, class)
        push!(subclasses, subclass)
    end
end

X = reduce(hcat, columns)

println("built $(nobs) observations by $(nvar) variables")

##########################################################################
# The fixtures                                                           #
##########################################################################
# The matrix goes to Helium as the other numeric fixtures do. The annotation is strings,
# so it goes to a tab separated file through DelimitedFiles, which is stdlib and needs no
# extra dependency in the test environment.
##########################################################################

Helium.writehe(X, joinpath(DATADIR, "grouped_correlation_data.he"))

writedlm(joinpath(DATADIR, "grouped_correlation_meta.tsv"),
         vcat(reshape(["name" "class" "subclass"], 1, 3),
              hcat(variable_names, classes, subclasses)))

println("wrote grouped_correlation_data.he and grouped_correlation_meta.tsv")

##########################################################################
# The reference image                                                    #
##########################################################################
# One reference, the default figure: both levels in their own label lanes, broadest
# outermost, fractions shown. The variants are covered by the series and annotation checks
# in the test file, which do not need an image to compare against.
##########################################################################

hierarchy = [classes, subclasses]

plt = plot_grouped_correlation(X, variable_names, hierarchy;
                               levelnames = ["Class", "Subclass"])

savefig(plt, joinpath(REFDIR, "grouped_correlation.png"))
println("wrote grouped_correlation.png")

println("done")