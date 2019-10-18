module Lookup
using Combinatorics
using ..PokerCard

export get_lexographically_next_bit_sequence, flush_lookup, unsuited_lookup

# ref lookup.py in deuces

"""
Number of Distinct Hand Values:
Straight Flush   10
Four of a Kind   156      [(13 choose 2) * (2 choose 1)]
Full Houses      156      [(13 choose 2) * (2 choose 1)]
Flush            1277     [(13 choose 5) - 10 straight flushes]
Straight         10
Three of a Kind  858      [(13 choose 3) * (3 choose 1)]
Two Pair         858      [(13 choose 3) * (3 choose 2)]
One Pair         2860     [(13 choose 4) * (4 choose 1)]
High Card      + 1277     [(13 choose 5) - 10 straights]
-------------------------
TOTAL            7462
Here we create a lookup table which maps:
    5 card hand's unique prime product => rank in range [1, 7462]
Examples:
* Royal flush (best hand possible)          => 1
* 7-5-4-3-2 unsuited (worst hand possible)  => 7462
"""

###############################
# SOME CONSTANTS
###############################
MAX_STRAIGHT_FLUSH  = 10
MAX_FOUR_OF_A_KIND  = 166
MAX_FULL_HOUSE      = 322
MAX_FLUSH           = 1599
MAX_STRAIGHT        = 1609
MAX_THREE_OF_A_KIND = 2467
MAX_TWO_PAIR        = 3325
MAX_PAIR            = 6185
MAX_HIGH_CARD       = 7462
MAX_TO_RANK_CLASS = Dict(
    MAX_STRAIGHT_FLUSH => 1,
    MAX_FOUR_OF_A_KIND => 2,
    MAX_FULL_HOUSE => 3,
    MAX_FLUSH => 4,
    MAX_STRAIGHT => 5,
    MAX_THREE_OF_A_KIND => 6,
    MAX_TWO_PAIR => 7,
    MAX_PAIR => 8,
    MAX_HIGH_CARD => 9
)
RANK_CLASS_TO_STRING = Dict(
    1 => "Straight Flush",
    2 => "Four of a Kind",
    3 => "Full House",
    4 => "Flush",
    5 => "Straight",
    6 => "Three of a Kind",
    7 => "Two Pair",
    8 => "Pair",
    9 => "High Card"
)
flush_lookup = Dict()
unsuited_lookup = Dict()
###############################
# BITHACK FUNCTION
###############################
function get_lexographically_next_bit_sequence(bits)
    """
    Bit hack from here:
    http://www-graphics.stanford.edu/~seander/bithacks.html#NextBitPermutation
    Generator even does this in poker order rank
    so no need to sort when done! Perfect.
    """
    bits = bits%UInt
    t = (bits | (bits -1)) + 1
    a = (t & -t)
    b = UInt(a) / UInt((bits & -bits))
    c = (UInt(b) >> UInt(1)) - 1
    next = UInt(t) | UInt(c)
    return (next)
end
###############################
# STRAIGHTS AND HIGHCARDS
###############################
function straight_and_highcards(straights, highcards)
    """
    Unique five card sets. Straights and highcards.
    Reuses bit sequences from flush calculations.
    """
    ### STRAIGHTS ###
    # since straights are weaker than flushes, we start iterating from there
    rank = MAX_FLUSH + 1
    for s in straights
        # iterate through the straights
        prime_product = PokerCard.prime_product_from_rankbits(s)
        unsuited_lookup[prime_product] = rank
        rank += 1
    end

    ### HIGH CARDS ###
    # high cards are weaker than pairs, we'll iterate after the weakest pair
    rank = MAX_PAIR
    for h in highcards
        prime_product = PokerCard.prime_product_from_rankbits(h)
        unsuited_lookup[prime_product] = rank
        rank += 1
    end
end # straight_and_highcards
###############################
# FLUSHES
###############################
function flushes()
    """
    Straight flushes and flushes.
    Lookup is done on 13 bit integer (2^13 > 7462):
    xxxbbbbb bbbbbbbb => integer hand index
    """
    flushes = []
    global straight_flushes = [
        7936, # int('0b1111100000000', 2), # royal flush
        3968, # int('0b111110000000', 2),
        1984, # int('0b11111000000', 2),
        992, # int('0b1111100000', 2),
        496, # int('0b111110000', 2),
        248, # int('0b11111000', 2),
        124, # int('0b1111100', 2),
        62, # int('0b111110', 2),
        31, # int('0b11111', 2),
        4111 # int('0b1000000001111', 2) # 5 high flush
    ]
    # start the current bit sequence

    # 1277 = number of high cards (ie no pairs = all unique ranks)
    # 1277 + len(str_flushes) is number of hands with all cards unique rank

    for i in 1:(1277 + length(straight_flushes) -1 )
        if i==1
            v = parse(UInt, "11111"; base=2)
            global current_bit_sequence = get_lexographically_next_bit_sequence(v)
        else
            global current_bit_sequence = get_lexographically_next_bit_sequence(current_bit_sequence)
        end

        notSF = true
        for sf in straight_flushes
            # if current_bit_sequence XOR sf == 0
            # then we have a sf and should not add
            if current_bit_sequence ⊻ sf == false
                notSF = false
            end
        end
        if notSF
            push!(flushes, current_bit_sequence)
        end
    end
    # we started from the lowest straight pattern, now we want to start ranking from
    # the most powerful hands, so we reverse
    reverse!(flushes)
    # now add to the lookup map:
    # start with straight flushes and the rank of 1
    # since theyit is the best hand in poker
    # rank 1 = Royal Flush!
    rank  = 1
    for sf in straight_flushes
        prime_product = PokerCard.prime_product_from_rankbits(sf)
        flush_lookup[prime_product] = rank
        rank += 1
    end
    # we start the counting for flushes starting from  max full house, which
    # is the worst rank that a full house can have (2,2,2,3,3)
    rank = MAX_FULL_HOUSE + 1
    for f in flushes
        prime_product = PokerCard.prime_product_from_rankbits(f)
        flush_lookup[prime_product] = rank
        rank += 1
    end
    @assert length(flush_lookup) == 1287 # 1277 flushes + 10 straight FLUSHES

    # make sure we account for the overlaps
    straight_and_highcards(straight_flushes, flushes)
end # flushes
###############################
# MULTIPLES
###############################
function multiples()
    """
    Pair, Two Pair, Three of a Kind, Full House, and 4 of a Kind.
    """
    backwards_ranks = reverse!(collect(1:13))

    ### FOUR OF A KIND
    rank = MAX_STRAIGHT_FLUSH + 1
    for i in backwards_ranks
        kickers = copy(backwards_ranks)
        filter!(e -> e ≠ i, kickers)
        for k in kickers
            product = (PokerCard.PRIMES[i] ^ 4) * PokerCard.PRIMES[k]
            unsuited_lookup[product] = rank
            rank +=1
        end
    end

    ### FULL HOUSE
    rank = MAX_FOUR_OF_A_KIND + 1
    for i in backwards_ranks
        pairranks = copy(backwards_ranks)
        filter!(e -> e ≠ i, pairranks)
        for pr in pairranks
            product = (PokerCard.PRIMES[i] ^ 3) * PokerCard.PRIMES[pr] ^ 2
            unsuited_lookup[product] = rank
            rank += 1
        end
    end

    ### THREE OF A KIND
    rank = MAX_STRAIGHT + 1
    for r in backwards_ranks
        kickers = copy(backwards_ranks)
        filter!(e -> e ≠ r, kickers)
        kickers_combos = collect(combinations(kickers, 2))
        for kickers in kickers_combos
            c1, c2 = kickers
            product = PokerCard.PRIMES[r]^3 * PokerCard.PRIMES[c1] * PokerCard.PRIMES[c2]
            unsuited_lookup[product] = rank
            rank += 1
        end

    end
    ### TWO PAIR
    rank = MAX_THREE_OF_A_KIND
    tpgen = collect(combinations(backwards_ranks, 2))
    for tp in tpgen
        pair1, pair2 = tp
        kickers = copy(backwards_ranks)
        filter!(e -> e ∉ tp, kickers)
        for kicker in kickers
            product = (PokerCard.PRIMES[pair1]^2) * (PokerCard.PRIMES[pair2])^2 * (PokerCard.PRIMES[kicker])
            unsuited_lookup[product] = rank
            rank += 1
        end
    end
    ### PAIRS
    rank = MAX_TWO_PAIR + 1
    for pairrank in backwards_ranks
        kickers = copy(backwards_ranks)
        filter!(e -> e ≠ pairrank, kickers)
        kgen = collect(combinations(kickers, 3))
        for kickers in kgen
            k1, k2, k3 = kickers
            product = PokerCard.PRIMES[pairrank]^2 * PokerCard.PRIMES[k1] * PokerCard.PRIMES[k2] * PokerCard.PRIMES[k3]
            unsuited_lookup[product] = rank
            rank += 1
        end
    end
end # multiples

function write_table_to_disk(table, filepath)
    open(filepath, "w") do io
        for val in table
            prime_prod = val[1]
            rank = val[2]
            write(io, "$prime_prod, $rank \n")
        end
    end
end


flushes()
multiples()

# write the table to disk
# write_table_to_disk(flush_lookup, "Data/LOOKUP_TABLE_FLUSH.csv")
# write_table_to_disk(unsuited_lookup, "Data/LOOKUP_TABLE_UNSUITED.csv")



end # Lookup module
