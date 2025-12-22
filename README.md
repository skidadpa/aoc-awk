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

| file          | description                                 |
| ------------- | ------------------------------------------- |
| Makefile      | Makefile that runs a regression by default  |
| expected.txt  | Expected results of sample regression       |
| sample.txt    | sample input from the challenge description |
| one.awk       | first solution                              |
| two.awk       | second solution                             |
| *             | additional files as needed                  |

And the first time run will automatically generate:

| input.txt     | test input from the challenge description   |
| reference.txt | results of each script on test input        |

Additionally, running the tests generates:

| results.txt   | results of each script on sample input      |
| output.txt    | results of each script on test input        |

Since it is protected by copyright and the Advent of Code maintainer has
requested that it not be published, test data is no longer included in
the repository. The tests now import test input using the 'aocd' tool
(see https://github.com/wimglenn/advent-of-code-data), which you must
install and configure with your session key. Test reference data will
be bootstrapped once from the inputs but is not automatically updated.
Since everyone can get different test input data, it is not guaranteed
that the test will actually work correctly with your data.

A starting template is in the template/ directory..

Jerry Williams
gsw@wfam.info
