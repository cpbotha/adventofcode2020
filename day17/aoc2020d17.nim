# part 1 plan:
# only record active cubes in hashset by their coordinates
# pretty happy that my first implementation of this worked the first time!
# part 2:
# copy pasted some code, added a "w" in everywhere and Bob was again my uncle.

import os, re, sequtils, sets, strformat, strscans, strutils, tables

let inputLines = readFile(joinPath(getAppDir(), "input.txt")).strip().split("\n")

type
  Coord = tuple[x,y,z: int]
  Coord4 = tuple[x,y,z,w: int]

# start with xyz = 0,0,0 at top left corner

proc doCycle(inWorld: HashSet[Coord]): HashSet[Coord] =
  # - only investigate positions on and directly neighbouring active cubes
  # - count active neighbours
  # - cube active and 2 OR 3 active neighbours: active else inactive
  # - cube inactive and exactly 3 active neighbours: active else inactive
  var newWorld = initHashSet[Coord]()

  for pos in inWorld:
    # foreach (pos and its neighbours)
    for z in pos.z-1..pos.z+1:
      for y in pos.y-1..pos.y+1:
        for x in pos.x-1..pos.x+1:
          # check whether it (x,y,z) becomes active or inactive
          # by 1. counting neighbours and 2. applying rules
          var numNeighbours = 0
          for zi in z-1..z+1:
            for yi in y-1..y+1:
              for xi in x-1..x+1:
                if xi == x and yi == y and zi == z:
                  # don't count ourselves
                  continue
                else:
                  if (xi,yi,zi) in inWorld:
                    numNeighbours += 1

          # apply rules
          if (x,y,z) in inWorld: 
            if numNeighbours == 2 or numNeighbours == 3:
              newWorld.incl((x,y,z))

          if (x,y,z) notin inWorld:
            if numNeighbours == 3:
              newWorld.incl((x,y,z))

  return newWorld


proc doCycle4(inWorld: HashSet[Coord4]): HashSet[Coord4] =
  # - only investigate positions on and directly neighbouring active cubes
  # - count active neighbours
  # - cube active and 2 OR 3 active neighbours: active else inactive
  # - cube inactive and exactly 3 active neighbours: active else inactive
  var newWorld = initHashSet[Coord4]()

  for pos in inWorld:
    # foreach (pos and its neighbours)
    for w in pos.w-1..pos.w+1:
      for z in pos.z-1..pos.z+1:
        for y in pos.y-1..pos.y+1:
          for x in pos.x-1..pos.x+1:
            # check whether it (x,y,z) becomes active or inactive
            # by 1. counting neighbours and 2. applying rules
            var numNeighbours = 0
            for wi in w-1..w+1:
              for zi in z-1..z+1:
                for yi in y-1..y+1:
                  for xi in x-1..x+1:
                    if xi == x and yi == y and zi == z and wi == w:
                      # don't count ourselves
                      continue
                    else:
                      if (xi,yi,zi,wi) in inWorld:
                        numNeighbours += 1

            # apply rules
            if (x,y,z,w) in inWorld: 
              if numNeighbours == 2 or numNeighbours == 3:
                newWorld.incl((x,y,z,w))

            if (x,y,z,w) notin inWorld:
              if numNeighbours == 3:
                newWorld.incl((x,y,z,w))

  return newWorld


proc doPart1(): int =
  # record only on = # positions
  var world = initHashSet[Coord]()

  # initialise the world
  var z = 0
  for y in 0..<inputLines.len:
    for x in 0..<inputLines[0].len:
      if inputLines[y][x] == '#':
        world.incl((x,y,z))

  for i in 1..6:
    world = doCycle(world)

  result = world.len

assert doPart1() == 401

proc doPart2(): int =
  # record only on = # positions
  var world = initHashSet[Coord4]()

  # initialise the world
  var
    z = 0
    w = 0
  for y in 0..<inputLines.len:
    for x in 0..<inputLines[0].len:
      if inputLines[y][x] == '#':
        world.incl((x,y,z,w))

  for i in 1..6:
    world = doCycle4(world)

  result = world.len

assert doPart2() == 2224
