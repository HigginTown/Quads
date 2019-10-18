module Quads
using Pkg
Pkg.add("Random")
Pkg.add("Combinatorics")
using Random
using Combinatorics

include("PokerCard.jl")
include("PokerDeck.jl")
include("Lookup.jl")
include("Evaluator.jl")



PokerCard.newCard("Ah")

export PokerCard
export PokerDeck
export Lookup
export Evaluatorus

end # module
