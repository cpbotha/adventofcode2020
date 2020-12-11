import algorithm, os, sequtils, sets, strformat, strutils, tables

var seats = readFile(joinPath(getAppDir(), "input.txt")).strip().split("\n")
let w = seats[0].len

proc numNbrsOccupied(r, c: int): int =
  result = 0
  
  for rn in r-1..r+1:
    if rn < 0 or rn > seats.len-1:
      continue
    for cn in c-1..c+1:
      if cn < 0 or cn > w-1:
        continue
      if rn == r and cn == c:
        # don't check ourselves skip to next column
        continue

      if seats[rn][cn] == '#':
        # TODO: in case of NO occupied neighbours check, you can early out here
        result += 1

proc transformSeat(r, c: int): char =
  let s = seats[r][c]
  if s == '.':
    return s
  
  let nbrsOcc = numNbrsOccupied(r, c)
  if s == 'L' and nbrsOcc == 0:
    return '#'
  if s == '#' and nbrsOcc >= 4:
    return 'L'

  return s

while true:
  # I would expect this to be a value copy
  var newSeats = seats
  for r in 0..seats.len-1:
    for c in 0..w-1:
      newSeats[r][c] = transformSeat(r,c)

  echo newSeats

  if newSeats == seats:
    break

  seats = newSeats

var numOcc = 0
echo seats.join("").count('#')
