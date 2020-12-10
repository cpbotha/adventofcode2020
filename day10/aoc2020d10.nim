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

import algorithm, os, sequtils, strformat, strutils, tables

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

  result = diffs[1] * diffs[3]

assert part1() == 2450
