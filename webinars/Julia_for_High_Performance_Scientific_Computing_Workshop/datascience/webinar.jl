using PalmerPenguins
using DataFrames


# example dataframe
names = ["Ali", "Clara", "Jingfei", "Stefan"]
age = ["25", "39", "64", "45"]

df = DataFrame(; name=names, age=age)  # the ; denotes keyword-argument use

# load penguin data into DataFrame using pipe |> operator
df = PalmerPenguins.load() |> DataFrame

first(df, 5) # see first 5 lines

# we observe that there are some missing values


df[1, 1:3]  # slicing first row

df[1:20:100, :island] # every 20 rows of island column

df.species # see one whole column

# get a copy of some columns
df[:, [:sex, :body_mass_g]]

# get a view (i.e. no copying) of a column
df[!, :bill_length_mm]

# get various sizes
size(df), ncol(df), nrow(df)

# find list of all unique entries
unique(df.species)

# generate summary statistics
describe(df)

# presence of Union{Missing, Float64} type suggests we have missing values we need to deal with
# one easy way is to just drop them
dropmissing!(df)


## Plotting

using Plots
gr()  # set backend to GR

x=1:10
y=rand(10,2)

plot(x,y, title="Two Lines", label=["Line 1", "Line 2"], linewidth=3)
xlabel!("x label")
ylabel!("y label")

# add new curve to the existing plot
z = rand(10)
plot!(x,z)

# save the plot to a file
savefig("myplot.png")


# multiple subplots:
y = rand(10, 4)

p1 = plot(x,y);
p2 = scatter(x, y);
p3 = plot(x,y, xlabel="This one is labeled", lw=3, title="subtitle");
p4 = histogram(x,y);
plot(p1,p2,p3,p4, layout=(2,2), legend=false)


# visualizing the penguin dataset
scatter(df[!, :bill_length_mm], df[!, :bill_depth_mm])
# adjust the marker colors and types
scatter(df[!, :bill_length_mm], df[!, :bill_depth_mm], marker=:hexagon, color=:magenta)

# change the plot theme: https://docs.juliaplots.org/latest/generated/plotthemes/
theme(:dao)
scatter(df[!, :bill_length_mm], df[!, :bill_depth_mm], marker=:hexagon, color=:magenta)

# add dimension by grouping by a third columns
scatter(df[!, :bill_length_mm],
        df[!, :bill_depth_mm],
        xlabel = "bill length (mm)",
        ylabel = "bill depth (g)",
        group = df[!, :species],
        marker = [:circle :ltriangle :star5],
        color = [:magenta :springgreen :blue],
        markersize= 5,
        alpha = 0.8
        )

# StatsPlots.jl provides more graph types
using StatsPlots

@df df density(:flipper_length_mm,
               xlabel = "flipper length (mm)",
               group = :species,
               color = [:magenta :springgreen :blue],)


# Traditional ML via MLJ.jl and ScikitLearn.jl
using MLJ
using Flux
