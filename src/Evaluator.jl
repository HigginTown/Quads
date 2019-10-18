module Evaluator
export evaluate

using Combinatorics
using Random
using ..PokerCard
using ..PokerDeck
using ..Lookup

unsuited_lookup = Lookup.unsuited_lookup
flush_lookup = Lookup.flush_lookup

# check we've covered all of the unique hands
@assert length(unsuited_lookup) + length(flush_lookup) == 7462

function five_card(cards::Array)
    # first we check for a flush
    cond = cards[1] & cards[2] & cards[3] & cards[4] & cards[5] & 61440 # 0xF000
    if sum(cond) > 0
        handOR = (cards[1] | cards[2] | cards[3] | cards[4] | cards[5]) >> 16
        prime = PokerCard.prime_product_from_rankbits(handOR)
        return Lookup.flush_lookup[prime]
    else
        prime = PokerCard.prime_product_from_hand(cards)
        return Lookup.unsuited_lookup[prime]
    end
end

function six_and_seven_card(cards::Array)
    """
    Performs five_card_eval() on all (6 choose 5) = 6 subsets
    of 5 cards in the set of 6 to determine the best ranking,
    and returns this ranking. Same for 7 cards.
    """
    minimum_score = Lookup.MAX_HIGH_CARD
    all5cardcombobs = collect(Combinatorics.combinations(cards, 5))
    for combo in all5cardcombobs
        score = five_card(combo)
        if score < minimum_score
            minimum_score = score
        end
    end
    return minimum_score
end

function evaluate(cards::Array)
    l = length(cards)
    @assert (4 < l < 8)
    if l > 5
        return six_and_seven_card(cards)
    else
        return five_card(cards)
    end
end

function get_rank_class(hr::Int)
    """
    Returns the class of hand given the hand hand_rank
    returned from evaluate.
    """
    if (hr >= 0) & (hr <= Lookup.MAX_STRAIGHT_FLUSH)
        return Lookup.MAX_TO_RANK_CLASS[Lookup.MAX_STRAIGHT_FLUSH]
    elseif hr <= Lookup.MAX_FOUR_OF_A_KIND
        return Lookup.MAX_TO_RANK_CLASS[Lookup.MAX_FOUR_OF_A_KIND]
    elseif hr <= Lookup.MAX_FULL_HOUSE
        return Lookup.MAX_TO_RANK_CLASS[Lookup.MAX_FULL_HOUSE]
    elseif hr <= Lookup.MAX_FLUSH
        return Lookup.MAX_TO_RANK_CLASS[Lookup.MAX_FLUSH]
    elseif hr <= Lookup.MAX_STRAIGHT
        return Lookup.MAX_TO_RANK_CLASS[Lookup.MAX_STRAIGHT]
    elseif hr <= Lookup.MAX_THREE_OF_A_KIND
        return Lookup.MAX_TO_RANK_CLASS[Lookup.MAX_THREE_OF_A_KIND]
    elseif hr <= Lookup.MAX_TWO_PAIR
        return Lookup.MAX_TO_RANK_CLASS[Lookup.MAX_TWO_PAIR]
    elseif hr <= Lookup.MAX_PAIR
        return Lookup.MAX_TO_RANK_CLASS[Lookup.MAX_PAIR]
    elseif hr <= Lookup.MAX_HIGH_CARD
        return Lookup.MAX_TO_RANK_CLASS[Lookup.MAX_HIGH_CARD]
    else
        throw(DomainError())
    end

end

function class_to_string(class_int::Int)
    """
    Converts the integer class hand score into a human-readable string.
    """
    return Lookup.RANK_CLASS_TO_STRING[class_int]
end

function get_five_card_rank_percentage(hand_rank::Int)
    """
    Scales the hand rank score to the [0.0, 1.0] range.
    """
    return float(hand_rank) / float(Lookup.MAX_HIGH_CARD)
end


end #Evaluator
