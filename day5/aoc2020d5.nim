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

# 128 rows and 8 columns of seats on the plane
# seats on very front and very back are also missing
# my seat is missing
# "the seats with IDs +1 and -1 from yours will be in your list"
# what is my seatId? == find gaps in ID

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

var occ = initCounttable[int]()
var maxId = -1
for line in lines:
  let seatId = calcSeatId(line)
  # track maxId for checksum
  if seatId > maxId:
    maxId = seatId

  # record that this seat is present
  occ.inc(seatId)

echo "maxid ", maxId

# now find holes in occ
for row in 0..127:
  for col in 0..7:
    let seatId = row*8+col
    if occ[seatId] == 0:
      echo &"{row} -- {col} -- {seatId}"

# there were a whole bunch of holes. it was clear however that the hole on row
# 72 col 3 seatId 579 was isolated, and hence mine

# I could have iterated through 0..maxSeatId; if curId not in list, but -1 and 1 are, there we are
# in other words:
for seatId in 0..maxId:
  if seatId notin occ and seatId-1 in occ and seatId+1 in occ:
    echo &"your seatId could be {seatId}"





