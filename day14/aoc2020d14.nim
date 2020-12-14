# AoC 2020 day 14 solution
# copyright 2020 by Charl P. Botha <info@charlbotha.com>
# BSD 3-clause thanks

import bitops, math, os, parseUtils, sequtils, strformat, strscans, strutils, tables

var instructions = readFile(joinPath(getAppDir(), "input.txt")).strip().split("\n")

proc doPart1(): int =
  var
    mem = newTable[int,int]()
    curMaskStr: string
    curAndMask: int
    curOrMask: int
    dummy: string
    ad: int
    val: int
  
  for li, l in instructions:
    if l.startsWith("mask"):
      curMaskStr = l["mask = ".len..^1]
      # use curAndMask to switch off bits
      let sa = cast[string](curMaskStr.mapIt(if it == '0': '0' else: '1'))
      curAndMask = parseBinInt(sa)
      # curOrMask to switch on bits
      let so = cast[string](curMaskStr.mapIt(if it == '1': '1' else: '0'))
      curOrMask = parseBinInt(so)

    else:
      # mem[8] = 11
      if scanf(l, "$w[$i] = $i", dummy, ad, val):
        # convert val to binary string, flip bits, convert back
        mem[ad] = bitand(bitor(val, curOrMask), curAndMask)

  result = toSeq(mem.values).foldl(a+b)

echo doPart1()
