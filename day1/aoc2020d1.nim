# AoC 2020 day 1 solution and experiments
# copyright 2020 by Charl P. Botha <info@charlbotha.com>
# BSD 3-clause thanks

# this contains a brute force example, slight refinements to that
# and then a slightly more clever approach with a hashset
# I also learned about seq slices creating new seqs (ouch)
# and how to work around this.

#{.experimental: "views".}
# it seems this is not required for toOpenArray after all
# with it activated, you'll run into:
# algorithm.nim(328, 7) Error: attempt to mutate a borrowed location from an immutable view
# when attempting the nums.sort()

import algorithm, os, sequtils, sets, strformat, strutils, times

proc find_sum2020_product(nums: seq[int]): int =
  # double iteration through nums
  for n0 in nums:
    for n1 in nums:
      if n0 + n1 == 2020:
        return n0 * n1

proc find_3sum2020_product_brute(nums: seq[int]): int =
  # triple iteration through nums
  for n0 in nums:
    for n1 in nums:
      for n2 in nums:
        if n0 + n1 + n2 == 2020:
          return n0 * n1 * n2

# instead of just brute-forcing through the whole cartesian product,
# we can of course skip the parts of that matrix we've already visited
# with my input list of 200 random unsorted ints, this was 3x faster
proc find_3sum2020_product_skip_indices(nums: seq[int]): int =
  for i0 in 0..nums.len-1:
    let n0 = nums[i0]
    for i1 in i0+1..nums.len-1:
      let n1 = nums[i1]
      for i2 in i1+1..nums.len-1:
        let n2 = nums[i2]
        if n0 + n1 + n2 == 2020:
          return n0 * n1 * n2

# you can rewrite the above more tersely as the following,
# but now it's SLOWER than the non-skip brute
# that's because those slices are returning new sequences every time:
# https://github.com/nim-lang/Nim/blob/version-1-4/lib/system.nim#L2542
# see https://forum.nim-lang.org/t/6469 (discussion re view slices, and araq: "In an ideal world we would have made a[x..y] an alias for toOpenArray"
# see https://nim-lang.github.io/Nim/manual_experimental.html#view-types for the experimental view types in 1.4
proc find_3sum2020_product_skip_slices(nums: seq[int]): int =
  # for index, element iteration see https://stackoverflow.com/a/48123056/532513 (implicit pair()!)
  for i0, n0 in nums:
    for i1, n1 in nums[i0+1..^1]:
      for i2, n2 in nums[i1+1..^1]:
        if n0 + n1 + n2 == 2020:
          return n0 * n1 * n2

# when I use toOpenArray, it is faster than skip_slices, but still 2x slower than skip_indices above
# in theory, this should be as fast as indices!
# no wait see notes below: depending on the sequence in which I run, this is == indices
# this toOpenArray seems to work even without experimental: views
proc find_3sum2020_product_skip_openarray(nums: seq[int]): int =
  # double iteration through nums
  # for index, element iteration see https://stackoverflow.com/a/48123056/532513
  for i0, n0 in nums:
    for i1, n1 in nums.toOpenArray(i0+1,nums.len-1): # ideally this would have been nums[i0+1..^1], but see above
      for i2, n2 in nums.toOpenArray(i1+1,nums.len-1):
        if n0 + n1 + n2 == 2020:
          return n0 * n1 * n2


# adapted from https://forum.nim-lang.org/t/4582#28715
# I'm yielding both index and value so that nim does not have to inject pair() itself
iterator span[T](s: seq[T]; first: int, last: BackwardsIndex): (int,T) =
  for i in first..s.len - last.int: yield (i,s[i])

# so this is even faster than the indices method
proc find_3sum2020_product_skip_iterator(nums: seq[int]): int =
  for i0, n0 in nums:
    for i1, n1 in nums.span(i0+1,^1):
      for i2, n2 in nums.span(i1+1,^1):
        if n0 + n1 + n2 == 2020:
          return n0 * n1 * n2

# translated from Dylan Bridgeman's ruby, improved with hashset for membership check
proc find_3sum2020_product_set(nums: seq[int]): int =
  let s = toHashSet(nums)
  for i0,n0 in nums.span(0,^1):
    let target1 = 2020 - n0
    if target1 < 0: continue
    for i1,n1 in nums.span(i0,^1):
      let target2 = target1 - n1
      if target2 in s:
        return n0*n1*target2

# filterIt was required for last blank line which would break parseInt
#var nums = f.split("\n").filterIt(it != "").mapIt(parseInt it)
# more streamlined, from https://www.reddit.com/r/adventofcode/comments/k4e4lm/2020_day_1_solutions/ge8g56f/
var nums: seq[int] = readFile(joinPath(getAppDir(),"input.txt")).strip().splitLines().map(parseInt)
# see below, pre-sorting leads to sub microsecond times
nums.sort()

# "my" part 1 answer was 471019
assert find_sum2020_product(nums) == 471019

# with the benchmarks below:
# if brute is at the start, indices is twice as fast as openarray
# if brute is at the end, or not executed, indices and openarray are equally fast
# furthermore, --gc:orc is a good chunk faster

#[
  sample results of run compiled with nim c --gc:orc -d:release

  1 µs is of course 1e-6 s

  without pre-sorting the input numbers:

  902.131 µs  indices
  1204.790 µs  openarray
  997.015 µs  span iter
  2734.433 µs  slices
  153.432 µs  set
  2734.677 µs  brute    

  with pre-sorting the input numbers:

  0.735 µs  indices
  0.451 µs  openarray
  0.493 µs  span iter
  1.330 µs  slices
  2.880 µs  set
  0.884 µs  brute

]#

let numRuns = 100
var t0: float
# "my" part 2 answer was 103927824
let part2answer = 103927824

proc durdisp(t0, t1: float): string =
  &"{(cpuTime() - t0) / float(numRuns) * 1e6:3.3f} µs"

t0 = cpuTime()
for i in 1..numRuns:
  assert find_3sum2020_product_skip_indices(nums) == part2answer
echo &"{durdisp(t0, cpuTime())}  indices"

t0 = cpuTime()
for i in 1..numRuns:
  assert find_3sum2020_product_skip_openarray(nums) == part2answer
echo &"{durdisp(t0, cpuTime())}  openarray"  

t0 = cpuTime()
for i in 1..numRuns:
  assert find_3sum2020_product_skip_iterator(nums) == part2answer
echo &"{durdisp(t0, cpuTime())}  span iter"  

t0 = cpuTime()
for i in 1..numRuns:
  assert find_3sum2020_product_skip_slices(nums) == part2answer
echo &"{durdisp(t0, cpuTime())}  slices"

t0 = cpuTime()
for i in 1..numRuns:
  assert find_3sum2020_product_set(nums) == part2answer
echo &"{durdisp(t0, cpuTime())}  set"

t0 = cpuTime()
for i in 1..numRuns:
  assert find_3sum2020_product_brute(nums) == part2answer
echo &"{durdisp(t0, cpuTime())}  brute"  


#[
  - what clever peeps on reddit were doing was searching rather than just
    checking, iow
  - for part A: for each elem in list, search for 2020-elem in list. With a set
    search O(1), you now have O(n) in total.
  - for part B: for each elem0 in list AND for each elem1 in list, find 2020 -
    elem0 - elem1 in the list.
    - when searching for elem1, it should be < (2020 - elem0). this can reduce
      the number of finds.

  Part 2 is apparently an instance of the 3SUM problem:
  https://en.wikipedia.org/wiki/3SUM
]#