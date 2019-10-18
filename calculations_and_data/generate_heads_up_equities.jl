import Quads.PokerCard
import Quads.PokerDeck
import Quads.Lookup
import Quads.Evaluator
import IterTools
import IterTools.subsets
import Random.shuffle
using Dates

function estimate_heads_up_equity(four_cards)
    # do 50k rollouts
    num_trials = 5 * 10^5
    # remove the four cards from the deck
    deck = PokerDeck.make_deck() # this deck is random
    remaining_cards = filter!(e -> e ∉ four_cards, deck)

    four_cards = collect(four_cards)

    hand_1 = four_cards[1:2]
    hand_2 = four_cards[3:4]

    # short circuit return 0.5 for pair v same pair

    if (PokerCard.get_rank_int(hand_1[1]) == PokerCard.get_rank_int(hand_2[1]) & PokerCard.get_rank_int(hand_1[2]) == PokerCard.get_rank_int(hand_2[2])) |
       (PokerCard.get_rank_int(hand_1[1]) == PokerCard.get_rank_int(hand_2[2]) & PokerCard.get_rank_int(hand_1[2]) == PokerCard.get_rank_int(hand_2[1]))
        return 0.5
    end
    all_possbile_boards = shuffle(collect(subsets(remaining_cards, Val{5}())))
    sample = all_possible_boards[1:num_trials]
    # keep a counter for hand_1_wins to calculate win rate
    hand_1_wins = 0
    # for each sample board join the hand and the sample board
    # then evaluate
    # add a point for the winner
    for i in 1:num_trials
        samp = collect(sample[i])
        hand_1 = hcat(four_cards[1:2], samp)
        hand_2 = hcat(four_cards[3:4], samp)
        if Evaluator.evaluate(hand_1) < Evaluator.evaluate(hand_2)
            hand_1_wins += 1
        elseif Evaluator.evaluate(hand_1) == Evaluator.evaluate(hand_2)
            hand_1_wins += .5
        end
    end
    return hand_1_wins/num_trials
end

function test_intuition(cards_as_strings)
    card_1 = cards_as_strings[1:2]
    card_2 = cards_as_strings[3:4]
    card_3 = cards_as_strings[5:6]
    card_4 = cards_as_strings[7:8]
    cards = PokerCard.newCard.([card_1, card_2, card_3, card_4])
    ret = estimate_heads_up_equity(cards)
    println("$cards_as_strings:  $ret")
    return ret
end

# @assert test_intuition("AhKd2h2c") > 0.25
# @assert test_intuition("AhKdAdKc") > 0.35
# @assert test_intuition("4h4d4c4s") > 0.35

function write_table_to_disk(table, filepath)
    open(filepath, "w") do io
        for val in table
            hands = val[1]
            equities = val[2]
            write(io, "$hands, $equities \n")
        end
    end
end

function generate_arrays()
    # Now let's go with the main routine
    all_possbile_hand_combos = collect(subsets(PokerDeck.make_deck(), Val(4)))
    partitions = collect(IterTools.partition(all_possbile_hand_combos, 1000))

    # for each partition evalute each matchup - roll out 50k random boards
    #  create a dict of 1000 matchups to write
    # and write it
    for (i, part) in enumerate(partitions)
        values = estimate_heads_up_equity.(part) # vectorized
        to_write = zip(part, values)
        write_table_to_disk(to_write, "equity_array_$i.csv")
        println(Dates.now())
    end
end

############
# PRECOMPUTE HEADS UP EQUITY ARRAYS PREFLOP
############

start = Dates.now()
println("$start , \n Generating... \n")

generate_arrays()

stop = Dates.now()
println(".... Done! \n $stop")

# write all hand combos
# write in batches in 1000 matchups
