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

assert doPart1() == 17028179706934

# 0 -> addrress bit unchanged
# 1 -> address bit overwritten with 1
# X - > address bit floating
proc doPart2(): int =
  var
    mem = newTable[int,int]()
    curMaskStr: string
    curAndMask: int
    curOrMask: int
    floatOffsets = newSeq[int]()
    dummy: string
    ad: int
    adStr: string
    val: int
  
  for li, l in instructions:
    if l.startsWith("mask"):
      curMaskStr = align(l["mask = ".len..^1], 36, padding='0')
      # curOrMask to switch on bits
      let so = cast[string](curMaskStr.mapIt(if it == '1': '1' else: '0'))
      curOrMask = parseBinInt(so)
      # now calculate the offsets that are floating
      floatOffsets = @[]
      for i,c in curMaskStr:
        if c == 'X':
          # offsets from the left
          floatOffsets.add(i)

    else:
      # mem[8] = 11
      if scanf(l, "$w[$i] = $i", dummy, ad, val):
        # switch on the 1 bits
        ad = bitor(ad, curOrMask)
        adStr = &"{ad:036b}"

        # now iterate through all of the float combos
        for i in 0..int(pow(2.0,float(floatOffsets.len)))-1:
          # convert current permutation to binary string in fstr
          #let fstr1 = &" what why???! {i}:b" <--- doh.
          var fstr: string
          formatValue(fstr, i, "b")
          fstr = align(fstr, floatOffsets.len, padding='0')

          for bidx, fb in fstr:
            adStr[floatOffsets[bidx]] = fb

          ad = parseBinInt(adStr)
          # now store at this modified address
          #echo floatOffsets
          #echo "addr: ", ad, " ", adStr, " maskstr ", curMaskStr
          mem[ad] = val

  result = toSeq(mem.values).foldl(a+b)

assert doPart2() == 3683236147222
