# Traditional ML via MLJ.jl and ScikitLearn.jl
using MLJ: partition, ConfusionMatrix
using Flux
using DataFrames
using PalmerPenguins

df = PalmerPenguins.load() |> DataFrame
dropmissing!(df)

# select feature and label columns
X = select(df, Not([:species, :sex, :island]))
Y = df[:, :species]  # NOTE: we are making copies here

# split into training and testing batches
(xtrain, xtest), (ytrain, ytest) = partition((X, Y), 0.8, shuffle=true, rng=123, multi=true)

# collect into arrays and transpose them (i.e. flux wants features: rows, instances: columns)
xtrain, xtest = Float32.(Array(xtrain)'), Float32.(Array(xtest)')

# one-hot encoding
ytrain = Flux.onehotbatch(ytrain, ["Adelie", "Gentoo", "Chinstrap"])
ytest = Flux.onehotbatch(ytest, ["Adelie", "Gentoo", "Chinstrap"])


# count the classes to see if our dataset is balanced
sum(ytrain, dims=2)
sum(ytest, dims=2)


# define a loss function
# we use cross-entropy since this is a classification task
loss(x, y) = Flux.crossentropy(model(x), y)

# onecold (inverse of one hot) to get back original repr
function accuracy(x, y)
    return sum(Flux.onecold(model(x)) .== Flux.onecold(y)) / size(y, 2)
end

# set up the model
n_features, n_classes, n_neurons = 4, 3, 10
model = Chain(
    Dense(n_features, n_neurons, sigmoid),
    Dense(n_neurons, n_classes),
    softmax
)

# define anonymous callback to show progress during training
callback = () -> @show(loss(xtrain, ytrain))

opt = ADAM()  # use default learning rate
θ = Flux.params(model)


# evaluate pre-training accuracy
model(xtrain[:, 1:5])
ytrain[:, 1:5]

# so .33333 would be what we'd expect for random guessing of class
accuracy(xtrain, ytrain)
accuracy(xtest, ytest)

# pass training data and targets as tuples to train!
# run 10 epochs
for i in 1:10
    Flux.train!(loss, θ, [(xtrain, ytrain)], opt, cb = Flux.throttle(callback, 1))
end

accuracy(xtrain, ytrain)
accuracy(xtest, ytest)

# create a confusion matrix to evaluate the result
predicted_species = Flux.onecold(model(xtest), ["Adelie", "Gentoo", "Chinstrap"])
true_species = Flux.onecold(ytest, ["Adelie", "Gentoo", "Chinstrap"])
ConfusionMatrix()(predicted_species, true_species)

# --------------------------------------------------------------------------------------------
# let's make a better solution using batch normalization and mini-batching
using StatsBase: sample

function create_minibatches(xtrain, ytrain, batch_size=32, n_batch=10)
    minibatches = Tuple[]
    for i in 1:n_batch
        randinds = sample(1:size(xtrain, 2), batch_size)
        push!(minibatches, (xtrain[:, randinds], ytrain[:,randinds]))
    end
    return minibatches
end

n_features, n_classes, n_neurons = 4, 3, 10
model = Chain(
        Dense(n_features, n_neurons),
        BatchNorm(n_neurons, relu),
        Dense(n_neurons, n_classes),
        softmax)

callback = () -> @show(loss(xtrain, ytrain))
opt = ADAM()
θ = Flux.params(model)

minibatches = create_minibatches(xtrain, ytrain)
for i in 1:100
    # train on minibatches
    Flux.train!(loss, θ, minibatches, opt, cb = Flux.throttle(callback, 1));
end

accuracy(xtrain, ytrain)
# 0.9849624060150376
accuracy(xtest, ytest)
# 0.9850746268656716

predicted_species = Flux.onecold(model(xtest), ["Adelie", "Gentoo", "Chinstrap"])
true_species = Flux.onecold(ytest, ["Adelie", "Gentoo", "Chinstrap"])

# we should come up with a way to make a pretty plot of this
confmat = ConfusionMatrix()(predicted_species, true_species)

typeof(confmat)
