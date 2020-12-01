# AoC 2020 day 1 solution and experiments
# copyright 2020 by Charl P. Botha <info@charlbotha.com>
# BSD 3-clause thanks

# this is mostly a brute-force example
# I did learn about seq slices creating new seqs (ouch)
# and how to work around this.

{.experimental: "views".}

import sequtils, strutils, times

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


let f = readFile("input.txt")
# filterIt was required for last blank line which would break parseInt
#let nums = f.split("\n").filterIt(it != "").mapIt(parseInt it)
# more streamlined, from https://www.reddit.com/r/adventofcode/comments/k4e4lm/2020_day_1_solutions/ge8g56f/
let nums = f.strip().splitLines().map(parseInt)

# "my" part 1 answer was 471019
assert find_sum2020_product(nums) == 471019

# with the benchmarks below:
# if brute is at the start, indices is twice as fast as openarray
# if brute is at the end, or not executed, indices and openarray are equally fast
# furthermore, --gc:orc is a good chunk faster

#[
  sample results of run compiled with nim c --gc:orc -d:release

  0.00124368625 indices
  0.0012070303 openarray
  0.00100139834 span iter
  0.002821317210000001 slices
  0.00275412723 brute
]#

let numRuns = 100
var t0: float
# "my" part 2 answer was 103927824
let part2answer = 103927824

t0 = cpuTime()
for i in 1..numRuns:
  assert find_3sum2020_product_skip_indices(nums) == part2answer
echo (cpuTime() - t0) / float(numRuns), " indices"

t0 = cpuTime()
for i in 1..numRuns:
  assert find_3sum2020_product_skip_openarray(nums) == part2answer
echo (cpuTime() - t0) / float(numRuns), " openarray"

t0 = cpuTime()
for i in 1..numRuns:
  assert find_3sum2020_product_skip_iterator(nums) == part2answer
echo (cpuTime() - t0) / float(numRuns), " span iter"

t0 = cpuTime()
for i in 1..numRuns:
  assert find_3sum2020_product_skip_slices(nums) == part2answer
echo (cpuTime() - t0) / float(numRuns), " slices"

t0 = cpuTime()
for i in 1..numRuns:
  assert find_3sum2020_product_brute(nums) == part2answer
echo (cpuTime() - t0) / float(numRuns), " brute"

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