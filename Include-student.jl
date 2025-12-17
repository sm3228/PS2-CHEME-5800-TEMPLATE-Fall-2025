# setup paths -
const _ROOT = @__DIR__
const _PATH_TO_DATA = joinpath(_ROOT, "data")
const _PATH_TO_SRC  = joinpath(_ROOT, "src")

using Pkg

# Always activate the local project first
Pkg.activate(_ROOT)

# If Manifest exists, just instantiate (no registry update needed)
if isfile(joinpath(_ROOT, "Manifest.toml"))
    Pkg.instantiate()
else
    # If no Manifest, add the Varnerlab package from GitHub (unregistered)
    Pkg.add(url="https://github.com/varnerlab/VLDataScienceMachineLearningPackage.jl.git")
    Pkg.resolve()
    Pkg.instantiate()
end

# load external packages -
using VLDataScienceMachineLearningPackage
using JSON
using JLD2
using FileIO
using KernelFunctions
using PrettyTables
using DataFrames
using Test
using Random
using Statistics
using LinearAlgebra
using BenchmarkTools
using Plots
using Colors
using DataStructures
using CSTParser
using GraphViz
using Distributions
using Images
using ImageInTerminal
using ImageShow

# include my codes -
include(joinpath(_PATH_TO_SRC, "Types.jl"))
include(joinpath(_PATH_TO_SRC, "Graphs.jl"))
