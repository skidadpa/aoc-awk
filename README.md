AWK solutions for Advent of Code
================================
I have been implementing the Advent of Code challenges in AWK. This is a
daily programming challenge created by Eric Wastl, which can be found at
http://www.adventofcode.com. These are my solutions.

This project combines solutions from multiple years and has an AWK library
(lib/aoc.awk) that can be reused from year to year. Daily solutions are in
per-year subdirectories. There were 25 challenge days from 2015 to 2024,
Eric switched to 12 days in 2025. Both start on December 1.

Generally my solution has folders for each day, each contain:

| file          | description                                 |
| ------------- | ------------------------------------------- |
| Makefile      | Makefile that runs a regression by default  |
| expected.txt  | Expected results of sample regression       |
| sample.txt    | sample input from the challenge description |
| one.awk       | first solution                              |
| two.awk       | second solution                             |
| *             | additional files as needed                  |

And the first time it is run will automatically generate:

| file          | description                                 |
| ------------- | ------------------------------------------- |
| input.txt     | test input from the challenge description   |
| reference.txt | results of each script on test input        |

Additionally, running the tests generates:

| file          | description                                 |
| ------------- | ------------------------------------------- |
| results.txt   | results of each script on sample input      |
| output.txt    | results of each script on test input        |

Since Eric requested that it not be published, input data is no longer
included in the repository. The makefiles now import test input using
the 'aocd' tool (see https://github.com/wimglenn/advent-of-code-data),
which must be installed and configured with your session key. Reference
results will be bootstrapped once from the inputs although it is not
automatically updated (it can be updated with 'make update' or by hand
as needed). Since input data is personalized, it is possible that any
given solution will not work correctly with your data, so check first
before relying on it.

Note that some of the problems require you to study the input data to
come up with a feasible solution. I try to add input checks when my
solution depends on some feature of the input data and throw an error
rather than continuing if the case is not met.

A starting template is in the template/ directory..

Jerry Williams
gsw@wfam.info
