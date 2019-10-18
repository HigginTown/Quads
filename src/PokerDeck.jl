module PokerDeck

export make_deck, ALL_CARDS_AS_STRING, draw!

using Random
using ..PokerCard

"""
Representing a deck. The first time we create, we seed the static
deck with the list of unique card integers.
"""
ALL_CARDS_AS_STRING = String[]

function make_deck()
    Deck = Integer[]
    for rank in PokerCard.STR_RANKS
        for suit in ['s', 'h', 'd', 'c']
            push!(ALL_CARDS_AS_STRING, rank * suit)
            push!(Deck, PokerCard.newCard(rank * suit))
        end
    end
    Random.shuffle!(Deck)
    return Deck
end

function draw!(number_of_cards::Integer, deck::Array)
    cards_drawn = Integer[]
    for i in 1:number_of_cards
        push!(cards_drawn, popfirst!(deck) )
    end
    return cards_drawn
end

end # end Deck
