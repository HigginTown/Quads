# using Quads
using Test
using Random

import Quads.PokerCard
import Quads.PokerDeck
import Quads.Lookup
import Quads.Evaluator

@testset "Quads.jl" begin
    # test the decks
    @test length(PokerDeck.make_deck()) == 52
    @test length(PokerDeck.draw!(5, PokerDeck.make_deck())) == 5

    # some hand and eval tests
    hand_string = ["2h", "3h", "4h", "5h", "Ah"]
    @test length(PokerCard.newCard.(hand_string)) == 5
    hand_ints = PokerCard.newCard.(hand_string)
    @test Evaluator.class_to_string(Evaluator.get_rank_class(Evaluator.evaluate(hand_ints))) == "Straight Flush"

    # seven cards from the deck and eval
    hand_ints = PokerDeck.draw!(7, PokerDeck.make_deck())
    @test typeof(PokerCard.int_to_pretty_str.(hand_ints)) == Array{String,1}
    @test typeof(Evaluator.get_rank_class(Evaluator.evaluate(hand_ints))) == Int

    # some timing tests for 1000 random draws and evals
    t = @elapsed for i in 1:1000
        hand_ints = PokerDeck.draw!(7, PokerDeck.make_deck())
        Evaluator.get_rank_class(Evaluator.evaluate(hand_ints))
    end

    # 1k draws and evals in under 1s
    @assert t < 1





end

# first we'll import our modules
