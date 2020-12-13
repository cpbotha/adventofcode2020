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
    t = 100_000_000_000_000
    # test_input
    #t = 1261410
    valid = false

  # find the largest bus number (in my case 601)
  let maxBus = buses2.max()
  let maxOffs = buses2.maxIndex()

  echo maxBus, " ", maxOffs

  # starting from the given startoffset, find first t+largestBusOffset that's divisible by largest bus
  # that t is our starting point
  var startFound = false
  while not startFound:
    if (t + maxOffs) mod maxBus == 0:
      startFound = true
    else:
      t += 1

  while not valid:
    valid = true
    for i in 0..buses2.len-1:
      if (t + offsets[i]) mod buses2[i] != 0:
        # this means this t is bad
        valid = false
        # don't do any more checking
        break
    # wo go in jumps of maxBus, because nothing else will be divisible by maxBus
    t += maxBus

    if t mod 1_000_000 == 0:
      echo t

  result = t - maxBus

echo doPart2()
#echo buses2
#echo offsets
