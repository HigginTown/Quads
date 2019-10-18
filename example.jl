# examples.jl

#Importing Modules
import Quads.PokerCard
import Quads.PokerDeck
import Quads.Lookup
import Quads.Evaluator


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

# working with a hand, eg evaluating a Straight Flush
hand_string = ["2h", "3h", "4h", "5h", "Ah"]
@assert length(PokerCard.newCard.(hand_string)) == 5
hand_ints = PokerCard.newCard.(hand_string)
println(Evaluator.class_to_string(Evaluator.get_rank_class(Evaluator.evaluate(hand_ints))))