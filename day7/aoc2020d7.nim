import os, re, sequtils, sets, strformat, strutils, tables

let lines = readFile(joinPath(getAppDir(), "input.txt")).strip().split("\n")
let re1 = re("^(.*) bags contain (.*)\\.")
let reBagStrip = re("(.*) bags?")

# for each unique colour, which other colours can contain it
var containedBy = newTable[string, HashSet[string]]()

for line in lines:
  # drab gold bags contain 3 dark maroon bags, 2 plaid beige bags.
  # () bags contain ().
  var groups: array[2, string]
  if match(line, re1, groups):
    # groups[0] == drab gold
    # groups[1] == 3 dark maroon bags, 2 plaid beige bags

    if groups[1].strip() != "no other bags":
      # strip bag(s) from end
      for cc in groups[1].split(", ").mapIt(it.split(" bag")[0]):
        # cc = 3 dark maroon bags
        let numThenColour = cc.split(" ", maxSplit=1)
        let num = parseInt(numThenColour[0].strip())
        let containedColour = numThenColour[1].strip()

        if containedColour notin containedBy:
          containedBy[containedColour] = initHashSet[string]()

        containedBy[containedColour].incl(groups[0])

  else:
    raise newException(ValueError, &"Could not parse {line}")


proc containedByRec(colour: string, allContainers: HashSet[string] = initHashSet[string]()): HashSet[string] =
  if colour in containedBy:
    # for each container colour, find out which colours can contain it by recursively calling this proc, and adding up all results
    return containedBy[colour].mapIt(containedByRec(it, allContainers + containedBy[colour])).foldl(a+b)
      
  else:
    # colour can't be contained by anything, so we're done
    return allContainers


assert containedByRec("shiny gold").len == 268
