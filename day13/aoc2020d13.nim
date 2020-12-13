# AoC 2020 day 13 solution
# copyright 2020 by Charl P. Botha <info@charlbotha.com>
# BSD 3-clause thanks

# gave up on part 2 after 1.5 hours

# from reddit it looks like when you have modular problems like this, bust out Chinese Remainder Theorem
# in this case, was even more straight-forward to notice prime numbers, then multiply them incrementally
# together for new step as you find more buses that work

# also:
# https://www.reddit.com/r/adventofcode/comments/kc4njx/2020_day_13_solutions/gfncyoc/
# The trick with part 2 was to quickly recognise that you could iterate over the
# numbers with a larger step value than 1. Once you find a satisfying value for
# each bus, you can then make the step value be the lowest common multiple of
# its current value and that bus. Fortunately the bus numbers were all mutually
# prime, so we didn't need to implement lowest common multiple and could simply
# multiply the step value.

# in other words:
# start from t until you find a t that satisfies the first bus, i.e. t mod bus == offset
# set step = found_bus
# when you find next bus, set step = found_buses.foldl(a*b)
# if the bus numbers were not prime, would have had to use LCM of found buses, or LCM of current step and new bus

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


# after 30 minutes with -d:danger, doPart2() below had reached 235_419_091_000_000
# with probably about 20 minutes more, it would have reached my answer!
# ignore mytime (line 1 of input)
# you can start at timestamp 100_000_000_000_000
proc doPart2(): int64 =
  var
    t = 100_000_000_000_000
    # test_input
    #t = 1161476
    # test_input_3
    #t = 1_102_161_486 #(answer is 1202161486)
    valid = false

  # find the largest bus number (in my case 601)
  let maxBus = buses2.max()
  # this cost me some time: using maxIndex() directly, instead of looking up in offsets
  let maxOffs = offsets[buses2.maxIndex()]

  #assert 100000000000245 + 37 mod 601 == 0

  echo buses2
  echo maxBus, " ", maxOffs

  # starting from the given startoffset, find first t+largestBusOffset that's divisible by largest bus
  # that t is our starting point
  var startFound = false
  while not startFound:
    if (t + maxOffs) mod maxBus == 0:
      startFound = true
    else:
      t += 1

  echo "starting from ", t

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

#echo doPart2()
#echo buses2
#echo offsets

# system of equations:
# t mod n0 = a0
# t mod n1 = a1
# ...
# where n0..nk are co-prime

echo buses2
echo offsets

proc doPart2Primes(): int64 =
  var
    #t = 100_000_000_000_000
    # test_input
    #t = 1161476
    # test_input_3
    t = 1_202_161_486 #(answer is 1_202_161_486)

  var step = 1
  for bi in 0..buses2.len-1:
    while true:
      if t == 1_202_161_486:
        echo bi, buses2
      #  return -1
      if (t + offsets[bi]) mod buses2[bi] == 0:
        # we've found the first t where this new bus can also work, so increment step
        step *= buses2[bi]
        # break out of while, so we can start with next bus
        break
      else:
        t += step

  result = t

echo "primes ", doPart2Primes()


proc mulInv(a0, b0: int): int =
  var (a, b, x0) = (a0, b0, 0)
  result = 1
  if b == 1: return
  while a > 1:
    let q = a div b
    a = a mod b
    swap a, b
    result = result - q * x0
    swap x0, result
  if result < 0: result += b0

# congruence equations: 
# a ≡ b (mod n)
# means a and b are congruent modulo n
# i.e. a - b is divisible by n

# from https://rosettacode.org/wiki/Chinese_remainder_theorem#Nim
# n should be divisors, a should be residuals
# for residuals, pass (bus - offset) because:
# (t + offs) mod bus == 0 :means
# t - (bus - offset) mod bus = 0 :means
# t ≡ (bus - offset) (mod bus)
# which is of the form: x ≡ a (mod n)
proc chineseRemainder[T](n, a: T): int =
  var prod = 1
  var sum = 0
  for x in n: prod *= x
 
  for i in 0..<n.len:
    let p = prod div n[i]
    sum += a[i] * mulInv(p, n[i]) * p
 
  sum mod prod

# 379_786_358_533_423 is correct
echo "CRT ", chineseRemainder(buses2, zip(offsets, buses2).mapIt(it[1] - it[0]))

