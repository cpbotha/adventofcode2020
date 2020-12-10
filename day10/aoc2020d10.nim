# AoC 2020 day 10 solution
# copyright 2020 by Charl P. Botha <info@charlbotha.com>
# BSD 3-clause thanks

# start part 1 at 08:04, completed at around 08:25

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
# start at level 0, the whole set. level 1 is a seq of hashsets, where each hashset contains only the removed adapter idx
# level 2 is a seq of hashsets, but here the hashsets have two elements, and so on.

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

proc checkValidSequence(excludedIndices: HashSet[int]): bool =
  var curVoltage = 0
  for idx, a in adapterOutputs:
    if idx in excludedIndices:
      continue
    let diff = a - curVoltage
    if diff >= 1 and diff <= 3:
      curVoltage += diff
    else:
      return false

  return curVoltage + 3 == deviceJoltage

# we start with a working sequence, we know this from part 1
var numSolutions = 1

proc walkTreeBT(excluded: HashSet[int] = initHashSet[int]()): int =
  # TODO: for new branches to the right, you don't have to check any of the candidates to their left
  var start = 0
  if excluded.len > 0:
    start = excluded.toSeq().max()

  for idx in start..adapterOutputs.len-1:
    # only echo progress on the outermost loop

    if excluded.len == 0: echo "==========> outside loop ", idx
    elif excluded.len <= 3: echo "exploring ", excluded

    if idx in excluded:
      # already excluded, so try and find another adapter to exclude
      continue
    
    # remove the candidate adapter
    let newBranch = excluded + toHashSet(@[idx])
    if checkValidSequence(newBranch):
      # valid solution
      numSolutions += 1
      # we need to continue down there
      discard walkTreeBT(newBranch)

  return numSolutions

echo walkTreeBT()
