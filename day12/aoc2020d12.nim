# AoC 2020 day 12 solution
# copyright 2020 by Charl P. Botha <info@charlbotha.com>
# BSD 3-clause thanks

import algorithm, math, os, sequtils, sets, strformat, strutils, tables

var instructions = readFile(joinPath(getAppDir(), "input.txt")).strip().split("\n")

# ship starts pointing E i.e. (1,0)
# consider as cartesian grid, W to E is negX to posX, S to N is negY to posY

let
  hToC = {'N': [0,1], 'S': [0,-1], 'E': [1,0], 'W': [-1,0]}.toTable

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

assert doPart1() == 923

