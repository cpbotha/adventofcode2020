import sequtils, tables

let input = @[0,20,7,16,1,18,15]

#let input = @[0,3,6]
# let input = @[2,3,1]

# turn index is 1-based
var tab = zip(input, toSeq(1..input.len)).toTable()

# we start right after the 0 that must have been uttered after the input sequence:
# tab is up to date to turn - 2
# lastNum is from turn - 1
# we are at turn
var lastNum: int = 0
var turn: int = input.len + 2
while turn <= 2020:
  if lastNum in tab:
    # last number spoken has already been spoken
    # get out its previous time
    let prevTime = tab[lastNum]
    # then store last round's time
    tab[lastNum] = turn - 1
    # then utter the difference
    lastNum = (turn - 1) - prevTime

  else:
    # this means the last number spoken was spoken for the first time
    # store its time
    tab[lastNum] = turn - 1
    # then utter 0
    lastNum = 0

  echo turn, " ", lastNum
  turn += 1

# 109 too low
echo lastNum

