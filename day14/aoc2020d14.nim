# AoC 2020 day 14 solution
# copyright 2020 by Charl P. Botha <info@charlbotha.com>
# BSD 3-clause thanks

# - here I just bit-twiddled everything
# - it was useful before the time seeing what the maximum number of X-floating bits were beforehand
# - some of the more elegant part 2 solutions would iterate through the mask, if run into X,
#   pop off stack, add two addresses with that X 0 and 1, then handle those two addresses, and so on.
#   this would end with stack of alternative addresses

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
      let sa = curMaskStr.mapIt(if it == '0': '0' else: '1').join()
      curAndMask = parseBinInt(sa)
      # curOrMask to switch on bits
      let so = curMaskStr.mapIt(if it == '1': '1' else: '0').join()
      curOrMask = parseBinInt(so)

    else:
      # mem[8] = 11
      if scanf(l, "$w[$i] = $i", dummy, ad, val):
        # convert val to binary string, flip bits, convert back
        mem[ad] = bitand(bitor(val, curOrMask), curAndMask)

  result = toSeq(mem.values).foldl(a+b)

assert doPart1() == 17028179706934

# maximum number of X bits == 9 in my input set
# this solution is instantaneous
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
        # then convert to 36 character wide bit string
        adStr = &"{ad:036b}"

        # now iterate through all of the float combos to get float bit permutations
        for i in 0..int(pow(2.0,float(floatOffsets.len)))-1:
          # convert current permutation to binary string in fstr
          var fstr = &"{i:b}"
          # leftpad 0 so it's as long as the full floatOffsets, so floatOffsets lookup will work
          fstr = align(fstr, floatOffsets.len, padding='0')

          for bidx, fb in fstr:
            adStr[floatOffsets[bidx]] = fb

          ad = parseBinInt(adStr)
          # now store at this modified address
          mem[ad] = val

  # sum up all of the values
  result = toSeq(mem.values).foldl(a+b)

assert doPart2() == 3683236147222
