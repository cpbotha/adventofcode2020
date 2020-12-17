# AoC 2020 day 17 solution
# copyright 2020 by Charl P. Botha <info@charlbotha.com>
# BSD 3-clause thanks

# part 1 plan =====
# only record active cubes in hashset by their coordinates
# pretty happy that my first implementation of this worked the first time!
# part 2 =====
# copy pasted some code, added a "w" in everywhere and Bob was again my uncle.

# General notes by a nim newbie:
# - It's really great that the built-in nim tuple is named; this together
#   with nim's type checking really helped to code up a working solution.
# - Coming from a 3D visualization background and having nim available, my
#   first thinking was to model this as an actual voxel grid. Fortunately
#   already corrected this in the thinking stage to a set *only* containing
#   the active coordinates.
# - the x,y,z symbolics helped me during writing this, but to make it
#   generic for N dimensions, one would write code to spit out a seq
#   with neighbour indices, and then follow the same logic. See e.g.
#   https://github.com/victorkirov/advent-of-code-2020/blob/master/2020/17/solution.py
#   - I have to resist the temptation to do this now.

#[
  Here is Keegan Carruther-Smith's commented Python to generate neighbour indices:

  def neigh(p):
    return (
      # p + dp
      tuple(a + b for a, b in zip(p, dp))
      # (-1, 0, 1) ** len(p)
      for dp in itertools.product(*[range(-1, 2)]*len(p))
      # Exclude (0, ..., 0)
      if any(a != 0 for a in dp))

  nim's algorithms module has "product"

]#

import os, sets, strutils

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
