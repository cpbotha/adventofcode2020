# AoC 2020 day 16 solution
# copyright 2020 by Charl P. Botha <info@charlbotha.com>
# BSD 3-clause thanks

# part 1 plan ===
# merge all valid intervals into combined valid interval(s)
# looking at the data, this could be trivial
# sorted, all of them have small gap in the middle, looks like gaps are covered by other intervals
# (yes, this turned out to be true)

# part 2 ===
# the solution formed as I was writing code
# made a misstep counting all of the valid intervals per field
# then realized I could rather just store a set containing for each field for which intervals it's valid for all examples
# then inspected those sets and was happy to see at least one with only one acceptable interval
# incrementally build on those known fields

import os, re, sequtils, sets, strformat, strscans, strutils, tables

# 0: intervals
# 1: my ticket, but ignore line 0
# 2: nearby tickets, but ignore line 0
let sections = readFile(joinPath(getAppDir(), "input.txt")).strip().split("\n\n")

# all nearby tickets that are valid
var validTickets = newSeq[seq[int]]()

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
    # here do the canonical check on each of the two merged ranges (if they don't merge into one)
    #totalInvalid += ticketStr.strip().split(",").map(parseInt).filterIt( not ((it >= min0g and it <= max0g) or (it >= min1g and it <= max1g)) ).foldl(a+b, 0)

    # count values that are outside of the merged valid range
    # this was a beautiful one-liner for part1, but split apart for re-use in part2
    let ticketNums = ticketStr.strip().split(",").map(parseInt)
    let invalidNumsTotal = ticketNums.filterIt(it < min0g or it > max1g).foldl(a+b, 0)
    # tally up for part1
    totalInvalid += invalidNumsTotal
    # keep track of all of the valid tickets
    if invalidNumsTotal == 0:
      validTickets.add(ticketNums)

  result = totalInvalid

assert doPart1() == 20013

proc doPart2(): int =
  # go through the 190 valid tickets in my case figuring out which field is which.
  # for each field, build up CountTable tallying up for which fields it's valid

  # first build up interval table
  let r = re("([\\w\\s]+): (\\d+)-(\\d+) or (\\d+)-(\\d+)")
  var intervals = initTable[string, seq[int]]()
  for spec in sections[0].split("\n"):
    var
      groups: array[5,string]
    
    if not spec.match(r, groups):
      raise newException(ValueError, &"could not parse {spec}")

    intervals[groups[0]] = groups[1..^1].map(parseInt)

  let myTicketNums = sections[1].split("\n")[1].split(",").map(parseInt)

  # start with each field that could potentially map to any valid field
  var couldBeValidFor = myTicketNums.mapIt(toSeq(intervals.keys()).toHashSet)
  for ticketNums in validTickets:
    for i, num in ticketNums:
      # now check field num against all intervals
      for descr, ivals in intervals:
        if not ((num >= ivals[0] and num <= ivals[1]) or (num >= ivals[2] and num <= ivals[3])):
          # INVALID: ith field can't be used for decription
          couldBeValidFor[i].excl(descr)

  # keep on looping through the per-field hashsets,
  # removing single occurrence field names from everywhere else
  # until each field only has a single occurrence
  var removedFields = initHashSet[string]()
  while couldBeValidFor.mapIt(len it).filterIt(it > 1).foldl(a+b, 0) > 0:
    for v in couldBeValidFor:
      if v.len == 1:
        # this means v has to be removed from all other sets
        let name = toSeq(v)[0] # stupid way to get element from set
        
        # we've already handled this one
        if name in removedFields:
          continue
        
        removedFields.incl(name)
        for vidx, vinner in couldBeValidFor:
          if vinner != v and name in vinner:
            #echo &"remove {name} from {vidx}"
            couldBeValidFor[vidx].excl(name)

        # stop the loop through CBVF so we can do another loop
        break

  var depProduct = 1
  for i, cb in couldBeValidFor:
    if toSeq(cb)[0].startsWith("departure"):
      depProduct *= myTicketNums[i]

  result = depProduct
  

assert doPart2() == 5977293343129

