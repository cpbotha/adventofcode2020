# AoC 2020 day 8 solution
# copyright 2020 by Charl P. Botha <info@charlbotha.com>
# BSD 3-clause thanks

# started part 1 at 8:25 solved at 8:40

import os, re, sequtils, sets, strformat, strscans, strutils, tables

let lines = readFile(joinPath(getAppDir(), "input.txt")).strip().split("\n")

var acc = 0
var ip = 0
var op: string
var x: int
# by default initialized to zero
var ip_map = newSeq[int](lines.len)

while true:
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

