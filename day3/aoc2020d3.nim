# AoC 2020 day 2 solution
# copyright 2020 by Charl P. Botha <info@charlbotha.com>
# BSD 3-clause thanks

# as usually the case, could only start at some time after 8 (UTC+2)
# part 1 took 5 to 10 minutes. answer 203
# part 2 start at 8:26 finish at 8:28

import os, sequtils, strscans, strutils, tables

# each line is a string of . (no trees) and # (trees)
let lines = readFile(joinPath(getAppDir(), "input.txt")).strip().splitLines()
let lineLen = lines[0].len

proc countTrees(dx, dy: int): int =
  # start at line 0, pos 0
  var row = 0
  var col = 0
  var numTrees = 0

  while true:
    if lines[row][col] == '#':
      numTrees += 1
    
    col += dx
    row += dy

    if row >= lines.len:
      return numTrees

    # wrap around simulates the repetition of the rows
    if col >= lineLen:
      col = col - lineLen

echo countTrees(1,1) * countTrees(3,1) * countTrees(5,1) * countTrees(7,1) * countTrees(1,2)

