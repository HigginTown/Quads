# partial port to Julia from Python -- python scoure:  https://github.com/worldveil/deuces/blob/master/deuces/card.py

module PokerCard

"""
We represent cards as 32-bit integers so there is no object instantiation -
they are just ints. Most of the bits are used and have a specific meaning.
See below:
                                PokerCard:
                    bitrank     suit rank   prime
              +--------+--------+--------+--------+
              |xxxbbbbb|bbbbbbbb|cdhsrrrr|xxpppppp|
              +--------+--------+--------+--------+

    1) p = prime number of rank (deuce = 2, trey = 3m four = 5, ..., ace = 41)
    2) r = rank of card (deuce = 0, trey = 1, four = 2, five = 3, ... ace = 12)
    3) cdhs = suit of the card (bit turned on based on suit of the card)
    4) b = bit it turned on depending on the rank of the card # 13 total
    5) x = unused bits

This will allow us to do very important things like:
    - Make a unique prime product for each hand
    - Detect flushes
    - Detect straights
    It is also quite performant.

""" 

STR_RANKS = "23456789TJQKA"
INT_RANKS = 1:13
PRIMES = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41]

# conversion from string => int
CHAR_RANK_TO_INT_RANK = Dict(zip(STR_RANKS, INT_RANKS))
CHAR_SUIT_TO_INT_SUIT = Dict(
    's' => 1, # spades
    'h' => 2, # hearts
    'd' => 4, # diamonds
    'c' => 8, # clubs
)

INT_SUIT_TO_CHAR_SUIT = "xshxdxxxc"

# pretty printing
PRETTY_SUITS = Dict(
    1 =>  string(Char(0x2660)), # spades
    2 =>  string(Char(0x2764)),  # hearts
    4 =>  string(Char(0x2666)), # diamonds
    8 =>  string(Char(0x2663)) # clubs
)


function newCard(card_string::String)
    """
    Converts Card string to binary integer representation, inspired by:
    http: //www dot suffecool dot net/poker/evaluator dot html

    # do not go to the site, it contains malware these days allegedly
    """

    rank_char = card_string[1]
    suit_char = card_string[2]

    rank_int = CHAR_RANK_TO_INT_RANK[rank_char]
    suit_int = CHAR_SUIT_TO_INT_SUIT[suit_char]
    rank_prime = PRIMES[rank_int]

    # now we can compose the unique 32 bit int
    bitrank  = 1 << (rank_int-1) << 16
    suit = suit_int << 12
    rank = (rank_int) << 8

    return bitrank | suit | rank | rank_prime
end

function get_rank_int(card_int::Integer)
    return (card_int >> 8) & 0xF
end

function get_suit_int(card_int::Integer)
    return (card_int >> 12) & 0xF
end

function int_to_str(card_int::Integer)
    rank_int = get_rank_int(card_int)
    suit_int = get_suit_int(card_int)
    return STR_RANKS[rank_int] *  INT_SUIT_TO_CHAR_SUIT[suit_int+1]
end

function get_bitrank_int(card_int::Integer)
    return (card_int >> 16) & 0x1FFF
end

function hand_to_binary(cards_strs::Array)
    """
    Expects a list of cards as strings and returns a list
    of integers of same length corresponding to those strings.
    """

    hand_ints = []

    for card_str in cards_strs
        push!(hand_ints, newCard(card_str))
    end
    return hand_ints
end

function prime_product_from_hand(card_ints::Array)
    product = 1
    for c in card_ints
        product *= (c & 0xFF)
    end

    return product
end

function prime_product_from_rankbits(rankbits)
    """
    Returns the prime product using the bitrank (b)
    bits of the hand. Each 1 in the sequence is converted
    to the correct prime and multiplied in.
    Params:
        rankbits = a single 32-bit (only 13-bits set) integer representing
                the ranks of 5 _different_ ranked cards
                (5 of 13 bits are set)
    Primarily used for evaulating flushes and straights,
    two occasions where we know the ranks are *ALL* different.
    Assumes that the input is in form (set bits):
                          rankbits
                    +--------+--------+
                    |xxxbbbbb|bbbbbbbb|
                    +--------+--------+
    """

    product = 1
    for i in 0:12
        # if the ith bit is set
        # println(bitstring(rankbits%UInt32))
        val = rankbits & (1 << i)
        if sum(val) > 0
            product *= PRIMES[i+1]
        end
    end
    return product
end

function int_to_pretty_str(card_int::Integer)
    suit_int = get_suit_int(card_int)
    rank_int = get_rank_int(card_int)

    r = STR_RANKS[rank_int]
    s = PRETTY_SUITS[suit_int]

    return "" * r*s * ""
end

end # PokerCard
