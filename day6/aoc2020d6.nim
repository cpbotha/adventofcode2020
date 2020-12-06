# AoC 2020 day 6 solution
# copyright 2020 by Charl P. Botha <info@charlbotha.com>
# BSD 3-clause thanks

# New nim-tricks I leanned today:
# - re"^$" is short for re("^$), but you need second form to add set of regex options

import os, sets, strutils, tables

# this time I'm simply splitting the input directly into groups
# instead of doing per-line parsing and grouping as with day 4.
# per-line would of course be the better real-world solution because
# can handle super large input files

# yes, you can split on a regex for the empty line
# let reEmptyLine = re("^$", {reMultiLine})
# let lines = readFile(joinPath(getAppDir(), "input.txt")).strip().split(reEmptyLine)
# but splitting on \n\n is cleverer. thanks sjvdwalt!
let lines = readFile(joinPath(getAppDir(), "input.txt")).strip().split("\n\n")

var totalYesCount = 0
var totalAllYesCount = 0
for group in lines:
  # "group" is now e.g.: nsi\nvlsgi\nins\nsi\n (i.e. after we split file on empty lines)
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

assert totalYesCount == 7128
assert totalAllYesCount == 3640
