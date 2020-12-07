# AoC 2020 day 7 solution
# copyright 2020 by Charl P. Botha <info@charlbotha.com>
# BSD 3-clause thanks

# new nim tricks I learned during this puzzle:
# - foldl(a+b)

# this took me longer than I would have liked :)

# later in the day:
# Next time I would like to try storing all the rules as a graph,
# with edge weights the multiplier into a colour node.
# part 1 is simply finding all paths terminating in the contained colour
# part 2 is traversing graph from shiny gold leaf

# found this nice explanation on reddit later:
# https://www.reddit.com/r/adventofcode/comments/k8a31f/2020_day_07_solutions/gexnf1d/?context=3
# Problem is a Directed Weighted Graph (possibly Acyclic but I didn't want to make that assumption).

# Part 0: Processing the input and creating a graph in adjacency list and
# adjacency matrix form :) A fun challenge for me in C++.

# Part 1: Reverse the Directed Graph (reverse the weighted edges) and traverse
# with DFS/BFS starting from the interested node ("shiny gold"). Count the
# vertices that this traversal hits (except the starting one).

# Part 2: DFS/BFS on the original Directed Graph, starting from the interested
# node ("shiny gold"), keeping a rolling multiplying count based on the weights
# (number of bags) on the edges of the neighbors.

import os, re, sequtils, sets, strformat, strscans, strutils, tables

let lines = readFile(joinPath(getAppDir(), "input.txt")).strip().split("\n")
let re1 = re("^(.*) bags contain (.*)\\.")

# for each unique colour, which other colours can directly contain it (part 1)
var containedBy = newTable[string, HashSet[string]]()

# for each unique colour, map to a list of name, numbers that it directly contains (part 2)
var containers = newTable[string, seq[(string, int)]]()

for line in lines:
  # drab gold bags contain 3 dark maroon bags, 2 plaid beige bags.
  # () bags contain ().
  var groups: array[2, string]
  if match(line, re1, groups):
    # groups[0] == drab gold
    # groups[1] == 3 dark maroon bags, 2 plaid beige bags

    if groups[1].strip() != "no other bags":
      containers[groups[0]] = @[]

      # strip bag(s) from end of each contained bag spec
      for cc in groups[1].split(", ").mapIt(it.split(" bag")[0]):
        # cc = "3 dark maroon"
        let numThenColour = cc.split(" ", maxSplit=1)
        let num = parseInt(numThenColour[0].strip())
        let containedColour = numThenColour[1].strip()

        if containedColour notin containedBy:
          containedBy[containedColour] = initHashSet[string]()

        containedBy[containedColour].incl(groups[0])

        # ... and also update the table for part 2
        containers[groups[0]].add((containedColour, num))

  else:
    raise newException(ValueError, &"Could not parse {line}")

# PART 1 ================
proc containedByRec(colour: string, allContainers: HashSet[string] = initHashSet[string]()): HashSet[string] =
  if colour in containedBy:
    # for each container colour, find out which colours can contain it by recursively calling this proc, and adding up all results
    return containedBy[colour].mapIt(containedByRec(it, allContainers + containedBy[colour])).foldl(a+b)
      
  else:
    # colour can't be contained by anything, so we're done
    return allContainers

assert containedByRec("shiny gold").len == 268

# PART 2 ================
proc countBagsContained(colour: string): int =
  if colour in containers:
    # count the bags directly contained (it[1])
    # then recurse down into contained bags, but remember to multiply it[1] with their answers
    result = containers[colour].mapIt(it[1] + it[1] * countBagsContained(it[0])).foldl(a+b)
  else:
    # this bag contains no bags
    result = 0

assert countBagsContained("shiny gold") == 7867
