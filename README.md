# Quads
### Fast Poker-hand evaluator

---------------

This library also contains useful functions for working with cards.
Every card is represented by a 32-bit integer. Most bits have a specific meaning.

**Example usage**

```
include("PokerCard.jl")
include("PokerDeck.jl")
include("Lookup.jl")
include("Evaluator.jl")

import Combinatorics
import IterTools
import Random


function test_user()
    println("TESTING...")
    # five card straight flush
    hand_string = ["2h", "3h", "4h", "5h", "Ah"]
    hand_ints = PokerCard.newCard.(hand_string) # vectorized
    println(map(PokerCard.int_to_pretty_str, hand_ints))
    println("Five card name: ", class_to_string(get_rank_class(evaluate(hand_ints))))

    # six card with shuffling
    hand_string = Random.shuffle!(["2c", "2h", "3h", "4h", "5h", "Ah"])
    hand_ints = PokerCard.newCard.(hand_string) # vectorized
    println(map(PokerCard.int_to_pretty_str, hand_ints))
    println("Six card hand rank: ", get_rank_class(evaluate(hand_ints)))

    # seven card from the deck
    hand_ints = PokerDeck.draw!(7, PokerDeck.make_deck())
    println(PokerCard.int_to_pretty_str.(hand_ints)) # vectorized
    println("Seven card random hand name: ", class_to_string(get_rank_class(evaluate(hand_ints))))
end

test_user()
```

gives

```
TESTING...
["2❤", "3❤", "4❤", "5❤", "A❤"]
Five card name: Straight Flush
["2♣", "4❤", "A❤", "3❤", "5❤", "2❤"]
Six card hand rank: 1
["J♠", "T♣", "7♦", "K♣", "2❤", "Q❤", "A♣"]
Seven card random hand name: Straight
```


-------

There are also some `csv` Lookup tables for flush and unsuited hands based on the hand integer representation scheme.

`LOOKUP_TABLE_FLUSH.csv`
`LOOKUP_TABLE_UNSUITED.csv`


--------------
