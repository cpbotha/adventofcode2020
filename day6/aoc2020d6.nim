# AoC 2020 day 6 solution
# copyright 2020 by Charl P. Botha <info@charlbotha.com>
# BSD 3-clause thanks

import os, re, sequtils, sets, strformat, strscans, strutils, tables

# this time simply munging directly into groups
# instead of doing per-line grouping as with day 4
let reEmptyLine = re("^$", {reMultiLine})
let lines = readFile(joinPath(getAppDir(), "input.txt")).strip().split(reEmptyLine)

var totalYesCount = 0
var totalAllYesCount = 0
for group in lines:
  # "group" is now e.g.: nsi\nvlsgi\nins\nsi\n (i.e. ater we split file on empty lines)
  let persons = group.strip().split()
  # a group of four persons now looks like e.g. @["nsi", "vlsig", "ins", "si"]
  # we join to create one string, and then simply count unique letters
  # answering question: to which questions did at least one person in group answer yes
  totalYesCount += persons.join("").toHashSet().len

  # part 2: to which questions did ALL persons in group answer yes?
  let numPersons = persons.len
  let count = persons.join("").toCountTable
  for k in count.keys():
    if count[k] == numPersons:
      totalAllYesCount += 1

echo totalYesCount
echo totalAllYesCount
