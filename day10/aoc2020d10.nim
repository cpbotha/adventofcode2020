# AoC 2020 day 10 solution
# copyright 2020 by Charl P. Botha <info@charlbotha.com>
# BSD 3-clause thanks

# - start part 1 at 08:04, completed at around 08:25
# - part 2: I could not get my backtracking to work on the full data. Gave up,
#   started looking at other people's solutions.

# next time:
# - try to sketch out the toy dataset and its deltas
# - then go through seeing what happens when you remove adapters
# - try to notice how the sub-solutions (windows of three adapters before the
#   current) accumulate into the total solution

# p1
# - input file has rated output joltages of adapters
# - each adapter can take input 1,2 or 3 jolts lower than its output
# - device rated for 3 jolts higher than highest adapter
# - charging outlet 0 jolts

# p2
# find subset Xk of Xm so that:
# 1 <= xn - xn-1 <= 3
# sum(xn - xn-1) = device
# 
# brute force:
# 104 adapters
# each adapter can be present or not, so 2^104 permutations
# BUT: an adapter can only be removed if the one at its output is <=3V

# backtracking
# - go through the whole set: if an adapter could be removed, that's a tree branch
# - for each branch, remove that adapter
#   - go through the set with the branch removed, for each OTHER adapter that can be removed, make a new branch
# - when done building the graph, count the nodes

# part 2 solutions from reddit https://www.reddit.com/r/adventofcode/comments/ka8z8x/2020_day_10_solutions/
# - dynamic programming, which is super fast, and is quite generic
# - peeps recognizing that sequences of joltage difference 1 result in specific
#   numbers of permutations for that sub-sequence
# - tribonacci

import algorithm, os, sequtils, sets, strformat, strutils, tables

var adapterOutputs = readFile(joinPath(getAppDir(), "input.txt")).strip().split("\n").mapIt(parseInt it)

# start by sorting!
adapterOutputs.sort()

# maximum + 3 for the device
let deviceJoltage = adapterOutputs[^1] + 3

proc part1(): int =
  var curVoltage = 0
  var diffs = initCountTable[int]()
  for a in adapterOutputs:
    let diff = a - curVoltage
    if diff >= 1 and diff <= 3:
      diffs.inc(diff)
      curVoltage += diff
    else:
      raise newException(ValueError, &"invalid adapter {a} for curVoltage {curVoltage}")

  # finally add 3 jolts diff to adapter!
  diffs.inc(3)

  assert curVoltage + 3 == deviceJoltage

  result = diffs[1] * diffs[3]

#assert part1() == 2450

# cache takes a lot of memory
#var cache = initTable[HashSet[int], bool]()
proc checkValidSequence(excludedIndices: HashSet[int]): bool =
  #if excludedIndices in cache:
  #  return cache[excludedIndices]

  var curVoltage = 0
  for idx, a in adapterOutputs:
    if idx in excludedIndices:
      continue
    let diff = a - curVoltage
    if diff >= 1 and diff <= 3:
      curVoltage += diff
    else:
      # invalid break in chain, early out
      return false

  # ensure that the last jump is valid
  result = curVoltage + 3 == deviceJoltage
  #cache[excludedIndices] = result

# we start with a working sequence, we know this from part 1
var numSolutions = 1

# quite bummed man
# this backtracking(ish) solution works for both the demo datasets,
# but doesn't get very far on my actual input after some minutes
proc walkTreeBT(excluded: HashSet[int] = initHashSet[int]()): void =
  var start = 0
  if excluded.len > 0:
    start = excluded.toSeq().max()

  for idx in start..adapterOutputs.len-1:
    # only echo progress on the outermost loop
    if excluded.len == 0: echo "==========> outside loop ", idx

    if idx in excluded:
      # already excluded, so try and find another adapter to exclude
      continue

    # exclude this candidate adapter
    let newBranch = excluded + toHashSet(@[idx])

    if newBranch.len > 0 and newBranch.len <= 3: echo "exploring ", newBranch

    # then check if we should count this solution as valid, and continue down the tree to extend it
    if checkValidSequence(newBranch):
      # valid solution
      numSolutions += 1
      #echo "total ", numSolutions, " solutions with ", newBranch
      # we need to continue down there
      walkTreeBT(newBranch)

# I could not get my backtracking algorithm above to work, and so turned to zatech:
# solveB below is a translation + commenting of Keegan Carruthers-Smith's DP solution in Python
# https://github.com/keegancsmith/advent/blob/master/2020/10/10.py
proc solveB(adapters: seq[int]): int =
   var dp = @[1]
   for i in 1..adapters.len-1:
       var acc = 0
       let x = adapters[i]

       # for the three adapters up to just before x, if diff is <= 3
       # it means that adapter can connect to x
       # (no point in going further back, because max diff is 3V)
       # for each of the previous solutions dp[j] this is a valid new solution, so accumulate
       for j in max(0, i-3)..i-1:
           if x - adapters[j] <= 3:
               # every valid short link to where I am now, means that all of the paths up to here
               # can be extended
               acc += dp[j]
       
       # when done accumulating, record for the next step
       dp.add(acc)

   return dp[^1]


#walkTreeBT()
#echo numSolutions

echo solveB(@[0] & adapterOutputs & @[deviceJoltage])
