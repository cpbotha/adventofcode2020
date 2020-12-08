# AoC 2020 day 8 solution
# copyright 2020 by Charl P. Botha <info@charlbotha.com>
# BSD 3-clause thanks

# started part 1 at 8:25 solved at 8:40
# part 2 finished at 9:08

import os, re, sequtils, sets, strformat, strscans, strutils, tables

var lines = readFile(joinPath(getAppDir(), "input.txt")).strip().split("\n")

proc runProg(): int =
  var acc = 0
  var ip = 0
  var op: string
  var x: int
  # by default initialized to zero
  var ip_map = newSeq[int](lines.len)

  while ip >= 0 and ip < lines.len:
    if ip_map[ip] > 0:
      raise newException(ValueError, &"Loop detected ip={ip} acc={acc} instruction={lines[ip]}")

    ip_map[ip] += 1

    if not scanf(lines[ip], "$w$s$i", op, x):
      raise newException(ValueError, &"Could not parse {lines[ip]}")

    case op
    of "nop":
      ip += 1

    of "acc":
      acc += x
      ip += 1

    of "jmp":
      ip += x

    else:
      raise newException(ValueError, &"Illegal instruction {lines[ip]}")

  # this means that ip went outside of the program, hopefully after end
  echo &"End of program with ip={ip}/{lines.len} acc={acc}"
  return acc


var accFinal: int = -1
for idx, line in lines:
  var changedJmpOrNop = 0
  if line.startsWith("jmp"):
    lines[idx] = line.replace("jmp", "nop")
    changedJmpOrNop = 1
  elif line.startsWith("nop"):
    lines[idx] = line.replace("nop", "jmp")
    changedJmpOrNop = 2

  if changedJmpOrNop > 0:
    try:
      accFinal = runProg()
      echo &"Final acc={accFinal}"
      break

    except ValueError:
      let e = getCurrentExceptionMsg()
      echo &"Error executing program: {e}"

    # change back
    if changedJmpOrNop == 1:
      lines[idx] = line.replace("nop", "jmp")
    else:
      lines[idx] = line.replace("jmp", "nop")
