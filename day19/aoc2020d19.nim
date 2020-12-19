# AoC 2020 day 19 solution
# copyright 2020 by Charl P. Botha <info@charlbotha.com>
# BSD 3-clause thanks

# part 1 plan ====
# - we want LUT with rulenum: regexp including
# - ok, at least I had the idea early on to pack rules into regexps
# - in spite of that, only had suitable data representation at third try (went to the beach in between)
#   1. seq of seqs nope
#   2. packing rulenums as ASCII chars into strings nope
#   3. map string to seq[string] in input Dict, string to regexp string in final dict yeah

# part 2 plan =====
# - whimper

import os, re, sequtils, sets, strformat, strscans, strutils, tables

# 0: rules
# 1: messages
let sections = readFile(joinPath(getAppDir(), "input.txt")).strip().split("\n\n")

# this is the desired ruledict
# map from string rule number to ready-to-go regexp
var reTable = initTable[string, string]()

# read input rules and return, also init reTable with the two known rules
proc extractInputRules(): Table[string, seq[string]] =
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
      # 
      let valseq = numval[1].strip().split(" ")
      result[numval[0]] = valseq
      
proc maybeParens(term: string): string =
  if term.contains("|"):
    &"({term})"
  else:
    term

proc doPart1(): int =
  var inputRules = extractInputRules()
  # scan repeatedly through input rules
  # until rule 0 is finalised with substitutions
  while "0" in inputRules:
    var toDelete = newSeq[string]()
    for ir_num, ir_seq in inputRules:

      # replace all tokens in input rule with final values that might exist in reTable
      # this means that a token in newSeq can be a string of characters starting with a or b
      let newSeq = ir_seq.mapIt(reTable.getOrDefault(it, it))

      if newSeq != ir_seq:
        # this means we have replaced stuff!
        # check if new rule is complete: only a, b, |
        if newSeq.allIt(it.startsWith("(") or it.startsWith("a") or it.startsWith("b") or it == "|"):
          # store in final reTable as a complete string
          reTable[ir_num] = maybeParens(newSeq.join())
          # schedule removal from inputRules
          toDelete.add(ir_num)
          
        else:
          # replaced previous rule with transformed rule
          inputRules[ir_num] = newSeq

    #now remove the rules that have graduated to reTable
    for ir_num in toDelete:
      inputRules.del(ir_num)

  # now check the messages
  # make sure we match the whole stringa
  let zre = re("^" & reTable["0"] & "$")
  result = sections[1].strip().splitLines().filterIt(it.match(zre)).len

echo doPart1()

#echo ord('b'), " ", ord('l')

#echo "90 90 | 132 128".split(" ").mapIt(if it == "|": '/' else: 'a').join()
