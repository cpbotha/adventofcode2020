# AoC 2020 day 2 solution
# copyright 2020 by Charl P. Botha <info@charlbotha.com>
# BSD 3-clause thanks

# Saturday, could only get started quite late

# One of my first thoughts was: This feels a lot like binary.
# Let's try the example:
# FBFBBFF
# 0  1  0 1 1 0 0
#64 32 16 8 4 2 1
# = 44
# haha nice

import os, sequtils, strscans, strutils, tables

let lines = readFile(joinPath(getAppDir(), "input.txt")).strip().splitLines()