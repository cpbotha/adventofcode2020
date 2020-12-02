# AoC 2020 day 2 solution
# copyright 2020 by Charl P. Botha <info@charlbotha.com>
# BSD 3-clause thanks

# according to dropbox, started at 08:06, finished at 08:49.
# that's 43 minutes with a whole bunch of home front interruptions,
# and welcoming guests into my home office

# as a nim newbie, impressed this time by: scanf, CountTable

import os, sequtils, strscans, strutils, tables

proc checkPP(pp: string): bool =
  var min, max: int
  var thechar, pass: string
  # e.g. 1-3 a: abcde
  # at least 1 x a, at most 3 x a
  if scanf(pp, "$i-$i $w: $w", min, max, thechar, pass):
    # https://nim-lang.org/docs/tables.html#basic-usage-counttable
    # we just count them all, you never know what's going to happen in part 2
    let freqs = toCountTable(pass)
    let freq = freqs[thechar[0]]
    return min <= freq and freq <= max
  else:
    raise newException(ValueError, "could not parse pp")

proc checkPP_p2(pp: string): bool =
  var p1, p2: int
  var thechar, pass: string
  if scanf(pp, "$i-$i $w: $w", p1, p2, thechar, pass):
    # for submitted solution, had counter variable, but this is simpler
    # one could also stick p1,p2 in an array, then .map() to do the below
    return count(@[pass[p1-1] == thechar[0], pass[p2-1] == thechar[0]], true) == 1
  else:
    raise newException(ValueError, "could not parse pp")

# pps = policy and password lines
let pps = readFile(joinPath(getAppDir(), "input.txt")).strip().splitLines()

var valids_p1 = 0
var valids_p2 = 0
for pp in pps:
  if checkPP(pp):
    valids_p1 += 1

  if checkPP_p2(pp):
    valids_p2 += 1


# should be 460
echo "p1: ", valids_p1
# should be 251
echo "p2: ", valids_p2
