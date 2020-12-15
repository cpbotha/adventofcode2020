# AoC 2020 day 15 solution
# copyright 2020 by Charl P. Botha <info@charlbotha.com>
# BSD 3-clause thanks

# for part 1, solution was already pretty efficient by only storing last occurrence of each number
# for part 2, only increased n to 30M: solution found in 1.26 us (-d:release -d:danger --gc:orc)

import sequtils, tables, times

let input = @[0,20,7,16,1,18,15]

#let input = @[0,3,6]
# let input = @[2,3,1]

proc nthNumberUttered(n: int): int =
  # turn index is 1-based
  var tab = zip(input, toSeq(1..input.len)).toTable()

  # we start right after the 0 that must have been uttered after the input sequence:
  # tab is up to date to turn - 2
  # lastNum is from turn - 1
  # we are at turn
  var lastNum: int = 0
  var turn: int = input.len + 2
  while turn <= n:
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

    #if turn mod 1_00_000 == 0:
    #  echo "progress ", turn

    turn += 1

  result = lastNum

# part 1
assert nthNumberUttered(2020) == 1025

# part 2
# with nim c --gc:orc -d:release -d:danger -r thisthing.nim
# this takes 1.26 microseconds
let t0 = cpuTime()
assert nthNumberUttered(30_000_000) == 129262
echo (cpuTime() - t0) * 1_000_000


