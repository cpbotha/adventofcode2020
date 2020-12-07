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
