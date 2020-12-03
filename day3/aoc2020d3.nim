# part 1 took 5 to 10 minutes

import os, sequtils, strscans, strutils, tables

# each line is a string of . (no trees) and # (trees)
let lines = readFile(joinPath(getAppDir(), "input.txt")).strip().splitLines()

let lineLen = lines[0].len
# start at line 0, pos 0
var row = 0
var col = 0
var atBottom = false
var numTrees = 0


while not atBottom:
  if lines[row][col] == '#':
    numTrees += 1
  
  col += 3
  row += 1

  if row >= lines.len:
    break

  # wrap around simulates the repetition of the rows
  if col >= lineLen:
    col = col - lineLen

echo numTrees

