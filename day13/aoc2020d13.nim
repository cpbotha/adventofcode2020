import math, os, sequtils, strutils, tables

let 
  lines = readFile(joinPath(getAppDir(), "input.txt")).strip().split("\n")
  mytime = parseInt lines[0]
  busesStr = lines[1]

let buses = busesStr.split(",").filterIt(it != "x").map(parseInt)

proc doPart1(): int =
  var
    t = mytime
    mybus = -1

  while mybus < 0:
    for bus in buses:
      if t mod bus == 0:
        mybus = bus
        # break from the for loop, then bus >= 0 will break from the while
        break
    t += 1

  result = mybus * (t - 1 - mytime)

#assert doPart1() == 3606

var
  offsets = newSeq[int]()
  buses2 = newSeq[int]()

for i, bs in busesStr.split(",").pairs():
  if bs != "x":
    offsets.add(i)
    buses2.add(parseInt(bs))

assert buses == buses2
# ensure that 0-offset (first) slot has a bus
assert offsets[0] == 0

# ignore mytime (line 1 of input)
# you can start at timestamp 100_000_000_000_000
proc doPart2(): int64 =
  var
    # test_input
    t = 100_000_000_000_000
    #t = 1261400
    valid = false

  while not valid:
    valid = true
    for i in 0..buses2.len-1:
      if (t + offsets[i]) mod buses2[i] != 0:
        # this means this t is bad
        valid = false
        # don't do any more checking
        break
    t += 1

    if t mod 1_000_000 == 0:
      echo t

  result = t-1

echo doPart2()
#echo buses2
#echo offsets
