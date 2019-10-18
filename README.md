#  ♠ ♢ Quads ♡ ♣
### Fast Poker-hand evaluator

A♠ A♢ A♡ A♣
---------------

This library also contains useful functions for working with cards.
Every card is represented by a 32-bit integer. Most bits have a specific meaning.

**Example usage**

Please see the examples in [`example.jl`](example.jl)

eg

```

# creating a deck
deck = PokerDeck.make_deck()

# there are 52 cards
@assert length(deck) == 52
# cards are integers
@assert typeof(deck[1]) == Int
#draw some cards
@assert length(PokerDeck.draw!(5, PokerDeck.make_deck())) == 5

# working wth cards
Ah = PokerCard.newCard("Ah") #268447017
@assert Ah == 268447017
@assert typeof(Ah) == Int
# there is a bitstring rep for each card that makes sense, check out PokerCard
@assert bitstring(Ah % UInt32) == "00010000000000000010110100101001"

```
