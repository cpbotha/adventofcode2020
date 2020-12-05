# AoC 2020 day 5 solution
# copyright 2020 by Charl P. Botha <info@charlbotha.com>
# BSD 3-clause thanks

# Saturday, could only get started quite late

# One of my first thoughts was: This feels a lot like binary.
# Let's try the example:
# FBFBBFF
# 0  1  0 1 1 0 0
#64 32 16 8 4 2 1
# = 44
# haha nice

import os, sequtils, strformat, strscans, strutils, tables

let lines = readFile(joinPath(getAppDir(), "input.txt")).strip().splitLines()

proc convertHalfSpecToNumber(halfSpec: string, zeroString: string, oneString: string): int =
  let binStr = halfSpec.replace(zeroString, "0").replace(oneString, "1")
  var num: int
  if not scanf(binStr, "$b", num):
    raise newException(ValueError, &"could not parse {binStr}")

  result = num

assert convertHalfSpecToNumber("FBFBBFF", "F", "B") == 44

proc calcSeatId(seatSpec: string): int =
  let rowPart = seatSpec[0..6]
  let row = convertHalfSpecToNumber(rowPart, "F","B")

  let colPart = seatSpec[7..9]
  let col = convertHalfSpecToNumber(colPart, "L","R")

  result = row * 8 + col

assert calcSeatId("FBFBBFFRLR") == 357

var maxId = -1
for line in lines:
  let seatId = calcSeatId(line)
  if seatId > maxId:
    maxId = seatId

echo maxId



