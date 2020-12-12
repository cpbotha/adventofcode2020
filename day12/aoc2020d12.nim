# AoC 2020 day 12 solution
# copyright 2020 by Charl P. Botha <info@charlbotha.com>
# BSD 3-clause thanks

# random nim newbie notes:
# - could have used 90,180,270 rotation lookup table but instead implemented
#   rotation matrix in p1. I am happier this way, would work for more.
# - https://github.com/unicredit/neo and/or
#   https://github.com/mratsim/Arraymancer for more serious LA / matrix support
#   in nim
# - thanks to rotation matrix, floating point rounding issue almost got me in
#   part 2.

import math, os, strutils, tables

var instructions = readFile(joinPath(getAppDir(), "input.txt")).strip().split("\n")

let
  hToC = {'N': [0,1], 'S': [0,-1], 'E': [1,0], 'W': [-1,0]}.toTable

# ship starts pointing E i.e. (1,0)
# consider as cartesian grid, W to E is negX to posX, S to N is negY to posY
proc doPart1(): int =
  var 
    curDir = [1,0]
    curPos = [0,0]

  for i in instructions:
    let o = i[0]
    let x = parseInt(i[1..^1])
    if o == 'F':
      curPos[0] += x * curDir[0]
      curPos[1] += x * curDir[1]
    elif o in ['L','R']:
      # do full rotation calc, will work for arbitrary angles
      # "rotates points in the xy-plane counterclockwise through an angle θ with respect to the x axis"
      let ar = degToRad(if o == 'R': -1*float(x) else: float(x))
      let newdx = float(curDir[0]) * cos(ar) - float(curDir[1]) * sin(ar)
      let newdy = float(curDir[0]) * sin(ar) + float(curDir[1]) * cos(ar)
      # for unit vectors, cast to int should just work here for new unit vectors
      curDir[0] = int(newdx)
      curDir[1] = int(newdy)
    else:
      let instDir = hToC[o]
      curPos[0] += x * instDir[0]
      curPos[1] += x * instDir[1]

  result = abs(curPos[0]) + abs(curPos[1])

echo doPart1() == 923

# encode waypoint position as relative to the ship
proc doPart2(): int =
  var 
    curPosS = [0,0]
    # always relative to ship!
    curPosW = [10,1]

  for i in instructions:
    let o = i[0]
    let v = parseInt(i[1..^1])
    if o == 'F':
      # move ship in direction of waypoint x times
      curPosS[0] += v * curPosW[0]
      curPosS[1] += v * curPosW[1]

    elif o in ['L','R']:
      # do full rotation calc, will work for arbitrary angles
      # "rotates points in the xy-plane counterclockwise through an angle θ with respect to the x axis"
      let ar = degToRad(if o == 'R': -1*float(v) else: float(v))
      let newdx = float(curPosW[0]) * cos(ar) - float(curPosW[1]) * sin(ar)
      let newdy = float(curPosW[0]) * sin(ar) + float(curPosW[1]) * cos(ar)
      # haha of course the round() here was necessary, else floats like 34.999999 will throw you
      curPosW[0] = int(round(newdx))
      curPosW[1] = int(round(newdy))

    else:
      # N,S,E,W -- move waypoint relative to s hip
      let instDir = hToC[o]
      curPosW[0] += v * instDir[0]
      curPosW[1] += v * instDir[1]

  result = abs(curPosS[0]) + abs(curPosS[1])

assert doPart2() == 24769

