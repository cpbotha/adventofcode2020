import os, re, sequtils, sets, strformat, strscans, strutils, tables

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
        let contig = nums[idx..i]
        return contig.min() + contig.max()

assert findMinMaxOfContigSum() == 4794981
