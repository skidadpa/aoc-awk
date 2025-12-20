#
# AWK library for Advent of Code challenges
#

@namespace "aoc"

##
# @brief Print an error message and exit
#
# Prints the provided error message and exits with code 1.
#
# @param e Message to print
#
# @Note Call once with no arguments at the start of END processing
# to cause the program to exit immediately when error() is called
# from pattern actions
#
function error(e) {
    if (_exit_code) {
        exit _exit_code
    }
    if (e) {
        print e
        exit _exit_code=1
    }
}

##
# Some initial defaults
#
# Overwrite in the regular program BEGIN handler
#
BEGIN {
    DEBUG = 0
    DFILE = "/dev/stderr"
}

#
# Propagate exit from any error() calls from pattern actions
#
# This should happen before the regular program END handler
#
END {
    error()
}

##
# @brief Print a data error message and exit
#
# Prints the provided error message along with the current line and
# line number and exits with code 1.
#
# @param e Message to print, can be empty
#
# @Note Intended to be used in a pattern action. Uses NR and $0.
#
function data_error(e,   sep) {
    if (e != "") {
        sep = " in: "
    }
    error("DATA ERROR at line " NR ": " e sep $0)
}

##
# @brief Print a runtime error message and exit
#
# Prints the provided error message, indicating that it is a
# processing error, and exits with code 1.
#
# @param e Message to print, can be empty
#
function compute_error(e,   sep) {
    if (e != "") {
        sep = ": "
    }
    error("PROCESSING ERROR" sep e)
}

##
# @brief Compute absolute value of a number
#
# @param x Number to process
#
# @return Absolute value of @x
#
function abs(x) {
    return x < 0 ? -x : x
}

##
# @brief Find the smallest of two numbers
#
# @param a Number to process
# @param b Number to process
#
# @return Minimum value
#
function min(a, b) { return a < b ? a : b }

##
# @brief Find the largest of two numbers
#
# @param a Number to process
# @param b Number to process
#
# @return Maximum value
#
function max(a, b) { return a > b ? a : b }
