# AoC 2020 day 9 solution
# copyright 2020 by Charl P. Botha <info@charlbotha.com>
# BSD 3-clause thanks

# fun, mostly brute-force index twiddling solution

# new nim that I (newbie) learned about:
# - I did not use this, but you can have "block" statements, and then "break"
#   out of that named block, see
#   https://nim-lang.org/docs/tut1.html#control-flow-statements-break-statement

import os, sequtils, strutils

let preambleLen = 25
let windowLen = preambleLen

var nums = readFile(joinPath(getAppDir(), "input.txt")).strip().split("\n").mapIt(parseInt it)

proc areThereNumsThatAddUpTo(idx: int): bool =
  result = false
  # outer loop skips last pos, because inner loop will go there
  for i in idx-windowLen..idx-2:
    for j in i+1..idx-1:
      if nums[i] + nums[j] == nums[idx]:
        return true

proc findFirstNumThatIsNotSum(): int =
  for idx in preambleLen..nums.len-1:
    let num = nums[idx]
    # now find two numbers in the windowLen behind us that add up to num
    if not areThereNumsThatAddUpTo(idx):
      # my answer is 32321523
      return num

  raise newException(ValueError, "No number that is the sum of two nums in preceding window")

let part1num = findFirstNumThatIsNotSum()
assert part1num == 32321523


# part 2 ==================

proc findMinMaxOfContigSum(): int =
  result = -1
  for idx in 0..nums.len-1:
    var sum = 0
    for i in idx..nums.len-1:
      sum += nums[i]
      if sum > part1num:
        # already too big, break out of the inner for loop
        break

      if sum == part1num:
        # this means everything from idx..i
        # this slice is a deep copy, but we're only doing it once
        let contig = nums[idx..i]
        return contig.min() + contig.max()

assert findMinMaxOfContigSum() == 4794981
