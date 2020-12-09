import os, re, sequtils, sets, strformat, strscans, strutils, tables

let preambleLen = 25
let windowLen = preambleLen

var nums = readFile(joinPath(getAppDir(), "input.txt")).strip().split("\n").mapIt(parseInt it)

proc areThereNumsThatAddUpTo(idx: int): bool =
  result = false
  echo idx
  # outer loop skips last pos, because inner loop will go there
  for i in idx-windowLen..idx-2:
    for j in i+1..idx-1:
      if nums[i] + nums[j] == nums[idx]:
        return true

for idx in preambleLen..nums.len-1:
  let num = nums[idx]
  # now find two numbers in the windowLen behind us that add up to num
  if not areThereNumsThatAddUpTo(idx):
    # my answer is 32321523
    echo "====> ", num
    break

  