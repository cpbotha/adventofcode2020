# part 1 plan ===
# merge all valid intervals into combined valid interval(s)
# looking at the data, this could be trivial
# sorted, all of them have small gap in the middle, looks like gaps are covered by other intervals

import os, sequtils, strformat, strscans, strutils, tables

# 0: intervals
# 1: my ticket, but ignore line 0
# 2: nearby tickets, but ignore line 0
let sections = readFile(joinPath(getAppDir(), "input.txt")).strip().split("\n\n")

proc doPart1(): int =
  var
    min0g,min1g = high(int)
    max0g,max1g = 0

  for spec in sections[0].split("\n"):
    var
      min0,max0,min1,max1: int
    
    # I should just have used re
    if not scanf(spec.split(": ")[1], "$i-$i or $i-$i", min0, max0, min1, max1):
      raise newException(ValueError, &"could not parse {spec}")

    min0g = min(min0, min0g)
    max0g = max(max0, max0g)

    min1g = min(min1, min1g)
    max1g = max(max1, max1g)

  # the valid ranges merge with the full set, but not with the demo set which I need for debugging
  # when it does merge, we only have to do a single interval check per ticket below
  assert min1g < max0g

  echo &"{min0g} - {max0g} or {min1g} - {max0g}"
  # yes, min0g - max1g is the complete valid range
  var totalInvalid = 0
  for ticketStr in sections[2].split("\n")[1..^1]:  
    # count values that are outside of the merged valid range
    totalInvalid += ticketStr.strip().split(",").map(parseInt).filterIt(it < min0g or it > max1g).foldl(a+b, 0)
    # here do the canonical check on each of the two merged ranges (if they don't merge into one)
    #totalInvalid += ticketStr.strip().split(",").map(parseInt).filterIt( not ((it >= min0g and it <= max0g) or (it >= min1g and it <= max1g)) ).foldl(a+b, 0)

  result = totalInvalid

# 252 or 48 is wrong
echo doPart1()



