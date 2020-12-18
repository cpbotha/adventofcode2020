# Pratt parser implemented with nim using npeg
# from https://www.reddit.com/r/adventofcode/comments/kfeldk/2020_day_18_solutions/gg8596t/
# commented example of Pratt parser:
# https://github.com/zevv/npeg/blob/11c9918ee3bb57c1107b42892f02a8025b40cdbe/tests/precedence.nim

import npeg, os, strutils, sequtils

proc eval(e: string): int =
  let parser = peg("stmt", userData: seq[int]):
    stmt <- expr * !1
    expr <- *' ' * prefix * *infix
    parenExp <- ( "(" * expr * ")" ) ^ 0
    lit <- >+Digit:
      userData.add parseInt($1)
    prefix <- lit | parenExp
    infix <- *' ' * ( sum | mul )
    sum <- >{'+','-'} * expr ^ 2:  # 2 for part1, 1 for part1
      let a, b = userData.pop
      if $1 == "+": userData.add a + b
      else: userData.add b - a
    mul <- >{'*','/'} * expr ^ 1:
      let a, b = userData.pop
      if $1 == "*": userData.add a * b
      else: userData.add b div a
  var stack: seq[int]
  doAssert parser.match(e, stack).ok
  assert stack.len == 1
  return stack[0]

let eqns = readFile(joinPath(getAppDir(), "input.txt")).strip().splitLines()
assert eqns.map(eval).foldl(a + b) == 328920644404583
