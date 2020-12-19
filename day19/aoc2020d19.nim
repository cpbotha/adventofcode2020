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
# - based on the two newly recursive rules, wrote out some examples of what would be valid
# - looking at patterns there, it seemed changing rule 42 to 42+ (i.e. one or more) and 31 to 31+
#   would work. This did work for the demo data, but not for the real data :(
# - finally figured out (still by myself) that the numbers 42 31 groups have to match! First
#   fixed by manually copying repetition groups (see below) to find right answer.
# - much later, saw on reddit https://www.reddit.com/r/adventofcode/comments/kg1mro/2020_day_19_solutions/ggcyjgo/
#   how to use PCRE's recursive capture groups and used that!

import os, re, sequtils, strformat, strutils, tables

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
    # enclose in a non-capturing group
    &"(?:{term})"
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

#assert doPart1() == 102
echo doPart1()


proc doPart2(): int =

  # rule 0 consists of 8 and 11, the two rules that are being changed

  reTable.clear()
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
          if ir_num == "8":
            # rule 8 is "42 | 42 8", which means one or more 42
            reTable[ir_num] = reTable[ir_num] & "+"
          elif ir_num == "11":
            # rule 11 is "42 31 | 42 11 31" which means one or more 42s followed by AN EQUAL NUMBER of 31s
            # let me cry for a bit, writing a regex that balances two groups of quantifier matches is tricky:
            # https://stackoverflow.com/questions/23001137/capturing-quantifiers-and-quantifier-arithmetic
            # I did try with just r42+r31+ (i.e. one or more of each) but then it let through too many messages
            # with real input data (it did work with demo data)
            # when I constrained the number of matches to be equal, then I could get the correct answer
            let r42 = reTable["42"]
            let r31 = reTable["31"]

            # ok crying a bit again... I kept on adding equal quantifiers for the two groups until I struck 318, and then site was happy
            #reTable[ir_num] = "(?:(" & r42 & r31 & ")|(" & r42 & "{2}" & r31 & "{2})|(" & r42 & "{3}" & r31 & "{3})|(" & r42 & "{4}" & r31 & "{4})|(" & r42 & "{5}" & r31 & "{5}))"

            # WAIT!
            # PCRE in nim DOES support recursive regular expressions
            # in the following, we name the whole expression itself "eleven" (could be anything unique)
            # then our existing r42, then we recurse into the whole group, then r31, 
            # which is of course 11 = 42 11 31
            reTable[ir_num] = &"(?<eleven>{r42}(?&eleven)?{r31})"

          # schedule removal from inputRules
          toDelete.add(ir_num)
          
        else:
          # replaced previous rule with transformed rule
          inputRules[ir_num] = newSeq

    # now remove the rules that have graduated to reTable
    for ir_num in toDelete:
      inputRules.del(ir_num)

  # now check the messages
  # make sure we match the whole string
  let zre = re("^" & reTable["0"] & "$")
  result = sections[1].strip().splitLines().filterIt(it.match(zre)).len


# 331 is too high
# 318 correct, after manually expanding regex to support up to 5 matches of 42 and 31
# 313 is too low
# 292 (adding option for 2 matches) too low
echo doPart2()
