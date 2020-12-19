# part 1 plan ====
# - we want LUT with rulenum: regexp including |
# - 
# 



import os, re, sequtils, sets, strformat, strscans, strutils, tables

# 0: rules
# 1: messages
let sections = readFile(joinPath(getAppDir(), "input.txt")).strip().split("\n\n")

# this is the desired ruledict
var reTable = initTable[char, string]()

# 108
const OR_CHAR = 'l'

# convert string rule number into its character encoding
proc encodeRuleNum(numStr: string): char =
  chr(ord(OR_CHAR) + parseInt(numStr))

# read input rules and return, also init reTable with the two known rules
proc extractInputRules(): Table[char, string] =
  var matches: array[5, string]
  let rdone = re("(\\d+): \"([a-b])\"")
  let rpipe = re("(\\d+): (\\d+) (\\d+) | (\\d+) (\\d+)")
  let rnopipe = re("(\\d+): (\\d+) (\\d+)")
  for ir in sections[0].split("\n"):
    # 99: "a" OR 7: 128 83 | 90 111 OR 67: 128 128 OR 132: 90 | 128
    if '"' in ir:
      if match(ir, rdone, matches):
        # this goes straight into the reTable
        reTable[encodeRuleNum(matches[0])] = matches[1]
      else:
        raise newException(ValueError, &"could not parse {ir}")

    else:
      let numval = ir.split(": ")
      # pack the whole rule value into a string
      let valstr = numval[1].strip().split(" ").mapIt(if it == "|": OR_CHAR else: encodeRuleNum(it)).join()
      result[encodeRuleNum(numval[0])] = valstr
      


proc doPart1(): int =
  let inputRules = extractInputRules()
  # scan repeatedly through input rules

  assert ord(OR_CHAR) + len(inputRules) < 255

  for ir_num, ir_val in inputRules:
    # go through ir_val, replacing each known rulenum
    for c in ir_val:
      if c in reTable:
        ir_val.replace(&"{c}", reTable[c])




echo doPart1()

#echo ord('b'), " ", ord('l')

#echo "90 90 | 132 128".split(" ").mapIt(if it == "|": '/' else: 'a').join()
