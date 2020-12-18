# TinBryn's shuntingYard implementation from  https://www.reddit.com/r/adventofcode/comments/kfeldk/2020_day_18_solutions/gg867ly/
# hooked it up to a rpnStack runner to check answer

import re, sequtils, strutils

# this spits out the whole equation as RPN, so you can just execute and put stuff on stack
# if precedence is true, + goes before *
iterator shuntingYard(exp: string, precedence: bool): string =
  let tokenPattern = re"\+|\*|\(|\)|\d+"
  var stack: seq[string]
  for token in exp.findAll(tokenPattern):
    case token:
    of "+":
      if stack.len > 0:
        case stack[^1]:
        of "+":
          yield stack.pop()
        of "*":
          if not precedence:
            yield stack.pop()
      stack.add token
    of "*":
      if stack.len > 0:
        case stack[^1]:
        of "+", "*":
          yield stack.pop()
      stack.add token
    of "(":
      stack.add token
    of ")":
      while stack.len > 0 and stack[^1] != "(":
        yield stack.pop()
      if stack.len > 0:
        discard stack.pop()
    else:
      yield(token)
  while stack.len > 0:
    yield stack.pop()

proc evalEqn(eqn: string): int =
  var rpnStack = newSeq[int]()
  for token in shuntingYard(eqn, true):
    case token
    of "+":
      rpnStack.add(rpnStack.pop() + rpnStack.pop())
    of "*":
      rpnStack.add(rpnStack.pop() * rpnStack.pop())
    else:
      rpnStack.add(parseInt(token))

  assert rpnStack.len == 1
  rpnStack[^1]

assert evalEqn("((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2") == 23340


