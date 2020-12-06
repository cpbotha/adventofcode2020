# AoC 2020 day 6 solution
# copyright 2020 by Charl P. Botha <info@charlbotha.com>
# BSD 3-clause thanks

import os, re, sequtils, sets, strformat, strscans, strutils, tables

# this time simply munging directly into groups
# instead of doing per-line grouping as with day 4
let reEmptyLine = re("^$", {reMultiLine})
let lines = readFile(joinPath(getAppDir(), "input.txt")).strip().split(reEmptyLine)

var totalYesCount = 0
for group in lines:
  # a group of four people looks like e.g. @["nsi", "vlsig", "ins", "si"]
  # we join to create one string, and then simply count unique letters
  # answering question: to which questions did at least one person in group answer yes
  totalYesCount += group.strip().split().join("").toHashSet().len

  # part 2: to which questions did ALL persons in group answer yes?

echo totalYesCount
