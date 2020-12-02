import algorithm, os, sequtils, sets, strformat, strscans, strutils, tables, times

proc checkPP(pp: string): bool =
    var min, max: int
    var thechar, pass: string
    if scanf(pp, "$i-$i $w: $w", min, max, thechar, pass):
        # https://nim-lang.org/docs/tables.html#basic-usage-counttable
        # we just count them all, you never know what's going to happen in part 2
        let freqs = toCountTable(pass)
        let freq = freqs[thechar[0]]
        return min <= freq and freq <= max

    else:
        raise newException(ValueError, "could not parse pp")


# pps = policy and password lines
# e.g. 1-3 a: abcde
# at least 1 x a, at most 3 x a
let pps = readFile(joinPath(getAppDir(),"input.txt")).strip().splitLines()

var valids = 0
for pp in pps:
    if checkPP(pp):
        valids += 1

echo valids
    
