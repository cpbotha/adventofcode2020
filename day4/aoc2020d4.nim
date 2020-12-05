# AoC 2020 day 2 solution
# copyright 2020 by Charl P. Botha <info@charlbotha.com>
# BSD 3-clause thanks

# was out of the day today; could only start this in the evening

# learned the lesson that re.match() by default does not mean to capture the whole input string
# iow, match("abcde", "abcd") will return true
# in my set, there were two pids with >9 digits. Enclosing re with ^ and $ fixed this.
# my bad, good lesson!

import os, re, sets, strformat, strscans, strutils, tables

# in this case DON'T strip, because we want that last empty line to trigger end of last passport
# my set check was wrong (< instead of <=); could fortunately debug with the demo set they gave!
let lines = readFile(joinPath(getAppDir(), "input.txt")).splitLines()

# cid is optional
let reqFields = toHashSet(["byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid"])

proc checkPassRequiredFields(fields: seq[string]): bool =
  # you have to do a subset or equality check, because passport could have more fields than required!
  result = reqfields <= fields.toHashSet()

let validEcl = toHashSet(["amb", "blu", "brn", "gry", "grn", "hzl", "oth"])

proc checkYearStr(yrstr: string, min, max: int): bool =
  result = true
  if yrstr.len != 4:
    return false
  let year = parseInt(yrstr)
  if year < min or year > max:
    result = false

proc checkPassValidValues(pass: TableRef[string,string]): bool =
  for key in pass.keys():
    if key == "byr":
      if not checkYearStr(pass[key], 1920, 2002):
        return false

    elif key == "iyr":
      if not checkYearStr(pass[key], 2010, 2020):
        return false

    elif key == "eyr":
      if not checkYearStr(pass[key], 2020, 2030):
        return false

    elif key == "hgt":
      var hgt: int;
      var unit: string;
      if scanf(pass[key], "$i$w", hgt, unit):
        if unit == "cm":
          if hgt < 150 or hgt > 193:
            return false
        elif unit == "in":
          if hgt < 59 or hgt > 76:
            return false
      else:
        echo "could not scan height!! ", pass[key]
        return false

    elif key == "hcl":
      if not match(pass[key], re"^#[0-9a-f]{6}$"):
        if match(pass[key], re"#[0-9a-f]{6}"):
          echo "hcl would have been OK ", pass[key]
        return false

    elif key == "ecl":
      if pass[key] notin validEcl:
        return false

    elif key == "pid":
      # 
      if not match(pass[key], re"^[0-9]{9}$"):
        if match(pass[key], re"[0-9]{9}"):
          echo &"pid would have been OK |{pass[key]}|"
        return false

  result = true

# parse out key:value pairs separated by spaces
# empty line separates passports

# these are just the keys
var thisPassFields = newSeq[string]()
var thisPass = newTable[string, string]()
var validPasses = 0
var numPasses = 0
for line in lines:
  # due to this check, important that the last line of the file is blank
  if line.strip() == "":
    numPasses += 1
    # end prev passport
    if thisPassFields.len > 0 and checkPassRequiredFields(thisPassFields):
      if checkPassValidValues(thisPass):
        validPasses += 1

    # start new passport
    # (unify with init code before the for loop)
    thisPassFields = @[]
    thisPass = newTable[string,string]()

  else:
    let terms = line.split(" ")

    for term in terms:
      let keyVal = term.split(":")
      thisPassFields.add(keyVal[0])
      thisPass[keyVal[0]] = keyVal[1]

# with only the required fields check, my answer was 213 valid / 279
# with the validity check, 148 / 279 was too high
echo validPasses, "/", numPasses
