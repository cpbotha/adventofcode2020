# part 1 plan ====
# - we want LUT with rulenum: regexp including |
# - 
# 



import os, re, sequtils, sets, strformat, strscans, strutils, tables

# 0: rules
# 1: messages
let sections = readFile(joinPath(getAppDir(), "input.txt")).strip().split("\n\n")

# this is the desired ruledict
var reTable = initTable[string, string]()

proc extractInputRules(): Table[string, seq[seq[string]]] =
  var matches: array[5, string]
  let rdone = re("(\\d+): \"([a-b])\"")
  let rpipe = re("(\\d+): (\\d+) (\\d+) | (\\d+) (\\d+)")
  let rnopipe = re("(\\d+): (\\d+) (\\d+)")
  for ir in sections[0].split("\n"):
    # 99: "a" OR 7: 128 83 | 90 111 OR 67: 128 128 OR 132: 90 | 128
    if '"' in ir:
      if match(ir, rdone, matches):
        # this goes straight into the reTable
        reTable[matches[0]] = matches[1]
      else:
        raise newException(ValueError, &"could not parse {ir}")

    else:
      let numval = ir.split(": ")
      # ruleval could contain |
      let ruleterms = numval[1].split("|")
      # each rule term should end up in seq[str]; it can contain arb number of nums
      result[numval[0]] = ruleterms.mapIt(it.strip().split(" ").mapIt(it.strip()))

proc doPart1(): int =
  let inputRules = extractInputRules()
  # scan repeatedly through input rules

  for num, rule in inputRules:
    var ruleDone = false
    for orterm in rule:
      for term in orterm:
        if term in reTable:
          echo "yargh, this is not going to work because have to add new orterms all the time!"



echo doPart1()
