AWK solutions for Advent of Code
================================
I have been implementing the Advent of Code challenges in AWK. This daily
programming challenge can be found at http://www.adventofcode.com. These
are my solutions.

This project combines solutions from multiple years and has an AWK library
(lib/aoc.awk) that can be reused from year to year. Daily solutions are in
per-year subdirectories (there were 25 challenge days every year through
2024, switching in 2025 to 12 days).

Generally the folders for each day, each contain:

| file         | description                                 |
| ------------ | ------------------------------------------- |
| Makefile     | Makefile that runs a regression by default  |
| expected.txt | Expected results of regression test         |
| sample.txt   | sample input from the challenge description |
| input.txt    | test input from the challenge description   |
| one.awk      | first solution                              |
| two.awk      | second solution                             |
| *            | additional files as needed                  |

Since it is protected by copyright and the Advent of Code maintainer has
requested that it not be published, test input is no longer included in
the repository although the tests will now automatically import it using
the 'aocd' tool (see https://github.com/wimglenn/advent-of-code-data),
which must be installed and configured with your session key. However,
since everyone can get different data, expected.txt may be wrong and the
implementation might not even work for your data. I plan to update the
mechanism to eliminate this issue, stripping this data from expected.txt
and providing a mechanism to cleanly bootstrap it.

A starting template is in template/day00/.

Jerry Williams
gsw@wfam.info
