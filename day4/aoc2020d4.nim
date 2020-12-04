# AoC 2020 day 2 solution
# copyright 2020 by Charl P. Botha <info@charlbotha.com>
# BSD 3-clause thanks

# was out of the day today; could only start this in the evening

import os, sets, strutils

# in this case DON'T strip, because we want that last empty line to trigger end of last passport
# my set check was wrong (< instead of <=); could fortunately debug with the demo set they gave!
let lines = readFile(joinPath(getAppDir(), "input.txt")).splitLines()

# cid is optional
let reqFields = toHashSet(["byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid"])

proc checkValidPass(fields: seq[string]): bool =
  # you have to do a subset or equality check, because passport could have more fields than required!
  result = reqfields <= fields.toHashSet()

# parse out key:value pairs separated by spaces
# empty line separates passports

var thisPassFields = newSeq[string]()
var validPasses = 0
var numPasses = 0
for line in lines:
  # due to this check, important that the last line of the file is blank
  if line.strip() == "":
    numPasses += 1
    # end prev passport
    if thisPassFields.len > 0 and checkValidPass(thisPassFields):
      validPasses += 1

    # start new passport
    thisPassFields = @[]

  else:
    let terms = line.strip().split(" ")

    for term in terms:
      let keyVal = term.split(":")
      thisPassFields.add(keyVal[0])

echo validPasses, "/", numPasses
