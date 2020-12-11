# AoC 2020 day 11 solution
# copyright 2020 by Charl P. Botha <info@charlbotha.com>
# BSD 3-clause thanks

# anniversary today, spent some minutes in the morning not solving part 1,
# continued after lunch (SAST). Was fun to do, probably only noteworthy
# item is that knowing raymarching means the implementation was straight-forward.

import os, strutils

var seats = readFile(joinPath(getAppDir(), "input.txt")).strip().split("\n")
let w = seats[0].len

# number of directly neighbouring seats occupied
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

proc transformSeatPart1(r, c: int): char =
  let s = seats[r][c]
  if s == '.':
    return s
  
  let nbrsOcc = numNbrsOccupied(r, c)
  if s == 'L' and nbrsOcc == 0:
    return '#'
  if s == '#' and nbrsOcc >= 4:
    return 'L'

  return s

proc doPart1(): int =
  # this time, we love nim copies!
  var savedSeats = seats
  while true:
    # thanks again nim value semantics!
    var newSeats = seats
    for r in 0..seats.len-1:
      for c in 0..w-1:
        newSeats[r][c] = transformSeatPart1(r,c)

    if newSeats == seats:
      break

    seats = newSeats

  result = seats.join("").count('#')

  # restore our initial data for part 2
  seats = savedSeats

assert doPart1() == 2178

proc numOccVis(r, c: int): int =
  result = 0
  
  for dy in -1..1:
    for dx in -1..1:
      if dx == 0 and dy == 0:
        continue

      # now raymarch
      var x = c
      var y = r
      while true:
        x += dx
        y += dy
        if x < 0 or x > w-1 or y < 0 or y > seats.len-1:
          # out of bounds, switch to next direction
          break
        if seats[y][x] == '#':
          # occupied seat visible, so count and then switch to next dir
          result += 1
          break
        if seats[y][x] == 'L':
          # empty seat visible, switch to next dir
          break

proc transformSeatPart2(r, c: int): char =
  let s = seats[r][c]
  if s == '.':
    return s
  
  let visOcc = numOccVis(r, c)
  if s == 'L' and visOcc == 0:
    return '#'
  if s == '#' and visOcc >= 5:
    return 'L'

  return s

# consider first seat a passenger sees gazing in each of eight different direction: occupied or empty?
# five or more visible occupied seats: occupied becomes empty
# empty seats that see no occupied seats become occupied
# count occupied seats at end
proc doPart2(): int =
  var savedSeats = seats
  while true:
    # thanks no nim value semantics, this is a copy!
    var newSeats = seats
    for r in 0..seats.len-1:
      for c in 0..w-1:
        newSeats[r][c] = transformSeatPart2(r,c)

    if newSeats == seats:
      break

    seats = newSeats

  result = seats.join("").count('#')

  # restore global variable, sorry mom
  seats = savedSeats

assert doPart2() == 1978