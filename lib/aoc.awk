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

##
# @brief Dump a matrix into a flat string
#
# @param mat Matrix to convert (2-dimensional, indexed [1,1]-[m,n]
# @param m number of rows (optional, auto-detected if not specified)
# @param n number of columns (optional, auto-detected if not specified)
#
# @return string of form [[row1 separated by commas][row2...
#
function str_mat(mat,   m, n,   i, c, j, str, sep) {
    if (!m) {
        m = 1
    }
    if (!n) {
        n = 1
    }
    if ((m == 1) || (n == 1)) {
        for (i in mat) {
            split(i, c, SUBSEP)
            if (m < 0 + c[1]) {
                m = 0 + c[1]
            }
            if (n < 0 + c[2]) {
                n = 0 + c[2]
            }
        }
    }
    str = "["
    for (i = 1; i <= m; ++i) {
        sep = "["
        for (j = 1; j <= m; ++j) {
            str = str sep mat[i,j]
            sep = ","
        }
        str = str "]"
    }
    str = str "]"
    return str
}

##
# @brief Dump a vector into a flat string
#
# @param vec Vector to convert (1-dimensional, indexed [1]-[m]
# @param m length of vector (optional, auto-detected if not specified)
#
# @return string of form [element, element, ...]
#
function str_vec(vec,   m,   str, sep, i) {
    str = ""
    sep = "["
    if (!m) {
        m = length(vec)
    }
    for (i = 1; i <= m; ++i) {
        str = str sep vec[i]
        sep = ","
    }
    str = str "]"
    return str
}

##
# @brief Perform Gaussian elimination on a coefficient matrix and result vector
#
# The arrays are updated in place, afterward the coefficient vector will be the
# identity matrix and the result vector will contain each coefficient's value
#
# @param [in,out] coeffs Coefficient vector indexed [1,1]-[n,n]
# @param [in,out] rhs Results vector indexed [1]-[n]
# @param n number of coeffients (optional, auto-detected in not specified)
#
function gaussianElimination(coeffs, rhs,   n,   i, pivot, j, k, factor) {
    if (!n) {
        n = length(rhs)
    }
    for (i = 1; i <= n; i++) {
        # Select pivot
        pivot = coeffs[i,i]
        # Normalize row i
        for (j = 1; j <= n; j++) {
            coeffs[i,j] = coeffs[i,j] / pivot
        }
        rhs[i] = rhs[i] / pivot
        # Sweep using row i
        for (k = 1; k <= n; k++) {
            if (k != i) {
                factor = coeffs[k,i]
                for (j = 0; j <= n; j++) {
                    coeffs[k,j] = coeffs[k,j] - factor * coeffs[i,j]
                }
                rhs[k] = rhs[k] - factor * rhs[i]
            }
        }
    }
}
