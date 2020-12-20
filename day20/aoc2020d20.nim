# AoC 2020 day 20 non-working attempt
# copyright 2020 by Charl P. Botha <info@charlbotha.com>
# BSD 3-clause thanks

# Sunday, day 20 this is where I dropped out :) (or at the very least gave up on this puzzle)
# this attempt contains some of my thinking until I decided enough

# part 1 plan =====
# - edge-matching puzzle with flips
# - encode each edge as binary number
# - matching edges are equal
# - if you flip a tile UD, only its LR side numbers are flipped, and vice versa.
#   - iow if you flip one edge, you have to flip the other
#   - do rotations after this
# - lookup table from edge number to tile number
# - backtracking could perhaps work
# - after a first check, it turns out that unflipped edges occur at most twice
#   iow not as hard as it appeared at first sight

# later:
# it turns out the problem was indeed very tightly constrained so you just had to slog through it placing tiles
# after having found the four corner tiles (tiles with two adjacent unique edges, unique even when flipped)

import algorithm, bitOps, os, parseUtils, re, sequtils, sets, strformat, strutils, tables

# 144 tile = 12*12
# each edge is 10 bits
let tiles = readFile(joinPath(getAppDir(), "input.txt")).strip().split("\n\n")

proc edgeToNum(edge: string): int =
  # # = 1, . = 0
  assert parseBin(edge.replace("#", "1").replace(".", "0"), result) == 10

# if edge is low number, reverseBits would give wrong answer
# we have to pad string repr to 10 bits, then reverse, then back to int
# BTW I love the nim ergonomics here of supporting return/result-less function returns
# feels a bit like f# in that sense also
proc flipIntEdge(edge: int): int =
  parseBinInt(reversed(&"{edge:010b}").join())  

var edgeToTile = initTable[int, HashSet[string]]()
var tileToEdges = initTable[string, array[4,int]]()

# encode tile edges as 4 integers which can be used for fast matching
proc preprocess(): void =
  for tile in tiles:
    let tileLines = tile.split("\n")

    # "Tile 3347:"
    let title = tileLines[0]

    # top
    let topEdge = edgeToNum(tileLines[1])
    # bottom
    let bottomEdge = edgeToNum(tileLines[^1])

    var leftEdgeStr, rightEdgeStr: string
    for i in 1..10:
      leftEdgeStr &= tileLines[i][0]
      rightEdgeStr &= tileLines[i][^1]

    # flip both the left and right edges so they read from bottom to top
    # if tile is rotated, they will be left to right, which is what we want
    let leftEdge = edgeToNum(reversed(leftEdgeStr).join())
    let rightEdge = edgeToNum(reversed(rightEdgeStr).join())

    # build lookup table from tile title to its four edges CW from top to left
    tileToEdges[title] = [topEdge, rightEdge, bottomEdge, leftEdge]
    # then stick each of those four edges into a edge -> tile SET lookup so we can quickly find the tile want
    for e in tileToEdges[title]:
      if edgeToTile.hasKeyOrPut(e, [title].toHashSet()):
        edgeToTile[e].incl(title)

  # end of for tile in tiles

  # make sure we have no edges encoding as 0
  # (our arrays are initialised to 0, that's why)
  assert min(toSeq(edgeToTile.keys())) > 0

type
  TTileLayout = array[12, array[12, tuple[title: string, right, bottom: int]]]
  TPlacedTiles = HashSet[string]

proc extendSolution(tileLayout: TTileLayout, placedTiles: TPlacedTiles): (TTileLayout, TPlacedTiles) =
  let
    row = (len(placedTiles)+1) div 12
    col = (len(placedTiles)+1) mod 12

  # row col is where we have to select a tile
  var
    leftEdge = 0
    topEdge = 0
    candidates: initHashSet[string]()

  if col - 1 >= 0:
    # this means we have a left edge
    leftEdge = tileLayout[row][col-1].right
    if leftEdge in edgeToTile:
      candidates.incl(edgeToTile[leftEdge])
    
    # now flip it

  if row - 1 >= 0:
    # this means we have a top edge
    topEdge = tileLayout[row-1][col].bottom

  # find tile that we can place


proc doPart1(): int =
  var
    # 12 rows of 12 columns
    tilelayout: TTileLayout
    placedTiles = initHashSet[string]()

  preprocess()

  # root of the BT tree branches out into 144 * 4 rotations * 2 flips per rotation (not flipped, flipped)
  for tile, edges in tileToEdges:
    for ei, edge in edges:
      for fEdge in [edge, flipIntEdge(edge)]:
        var bottomEdge: int
        if fEdge == edge:
          bottomEdge = edges[if ei + 1 < edges.high(): ei+1 else: 0]
        else:
          # flipped edge, brain asplode!
          # well actually when right edge has been flipped, it means bottom edge is what
          # was top edge (-1) before the flip thanks
          bottomEdge = edges[if ei - 1 < 0: edges.high() else: ei - 1]
          
        tileLayout[0][0] = (tile, fEdge, bottomEdge)
        placedTiles.incl(tile)

        echo extendSolution(tilelayout, placedTiles)


  #echo fitTiles(tileLayout, placedTiles)



echo doPart1()

# now let's place the tiles
# backtrack over 144 branches

