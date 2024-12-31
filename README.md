AWK solutions for Advent of Code
================================
I have been implementing the Advent of Code challenges in AWK. This daily
programming challenge can be found at http://www.adventofcode.com. These
are my solutions.

This project combines solutions from multiple years and has an AWK library
(lib/aoc.awk) that can be reused from year to year. Daily solutions are in
per-year subdirectories (there are 25 challenge days every year).

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

A starting template is in template/day00/.

Jerry Williams
gsw@wfam.info
