# part 1 =========
# started at about 7:35 SAST, done at 8:14
# again quite chuffed that my first implementation worked the first time!
# HOWEVER, recursive parser took advantage of left-to-right precedence with
# simple acc + op logic

# part 2 ======

import os, re, sets, sequtils, strformat, strutils

let eqns = readFile(joinPath(getAppDir(), "input.txt")).strip().split("\n")

proc applyToAcc(acc: var int, x: int, op: string): void =
  if op == "+":
    acc += x
  elif op == "*":
    acc *= x
  else:
    raise newException(ValueError, &"unknown op {op}")


# return accumulator, current i
proc evalEqn(eqn: string, startidx: int = 0): (int, int) =
  let numRe = re("([0-9]+)")
  var numMatches: array[1, string]
  # scan left to right, eating tokens
  var acc = 0
  # should be enum
  var curOp = "+"
  var i = startidx
  while i < eqn.len:
    let c = eqn[i]
    if c == ' ':
      i+=1
      continue
    elif eqn.match(numRe, numMatches,i):
      # we have found a number, add / mul into accumulator
      applyToAcc(acc, parseInt(numMatches[0]), curOp)
      i += numMatches[0].len
    elif c == '+':
      curOp = "+"
      i += 1
    elif c == '*':
      curOp = "*"
      i += 1
    elif c == '(':
      let ai = evalEqn(eqn, i+1)
      applyToAcc(acc, ai[0], curOp)
      # new i after the nested expression
      i = ai[1]
    elif c == ')':
      # step over the ), then return our accumulated value so parent can run with it
      i += 1
      break

  result = (acc, i)

    


    

proc doPart1(): int =
  eqns.mapIt(evalEqn(it)[0]).foldl(a+b)

echo doPart1()
