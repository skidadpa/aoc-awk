#
# AWK library for Advent of Code challenges
#

@namespace "aoc"

##
# @brief Print an error message and exit.
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
# @brief Provide some initial defaults.
#
# Overwrite in the regular program BEGIN handler as needed.
#
BEGIN {
    DEBUG = 0
    DFILE = "/dev/stderr"
}

#
# @brief Propagate exit from any error() calls from pattern actions.
#
# This will happen before the regular program END handler.
#
END {
    error()
}

##
# @brief Print a data error message and exit.
#
# Prints the provided error message along with the current line and
# line number and exits with code 1.
#
# @param e Message to print (optional)
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
# @brief Print a runtime error message and exit.
#
# Prints the provided error message, indicating that it is a
# processing error, and exits with code 1.
#
# @param e Message to print (optional)
#
function compute_error(e,   sep) {
    if (e != "") {
        sep = ": "
    }
    error("PROCESSING ERROR" sep e)
}

##
# @brief Compute absolute value of a number.
#
# @param x Number to process
#
# @return Absolute value of @x
#
function abs(x) {
    return x < 0 ? -x : x
}

##
# @brief Compute manhattan distance between two points in varying dimensions.
#
# Either provide the coordinates of each dimension in sequence (i.e., x1, x2, y1, y2, etc.)
# for up to 6 dimensions OR provide two points with an arbitrary number of dimensions,
# separated by SUBSEP (i.e., (x1 SUBSEP y1 SUBSEP z1 ...), (x2 SUBSEP y2 ...)).
#
# @param a1 First point, first axis coordinate OR all coordinates
# @param a2 Second point, first axis coordinate OR all coordinates
# @param b1 First point second axis coordinate (optional)
# @param b2 Second point second axis coordinate (optional)
# @param c1 First point third axis coordinate (optional)
# @param c2 Second point third axis coordinate (optional)
# @param d1 First point fourth axis coordinate (optional)
# @param d2 Second point fourth axis coordinate (optional)
# @param e1 First point fifth axis coordinate (optional)
# @param e2 Second point fifth axis coordinate (optional)
# @param f1 First point sixth axis coordinate (optional)
# @param f2 Second point sixth axis coordinate (optional)
#
# @return Sum of the differences of coordinates from all axes
#
function manhattan(a1, a2, b1, b2, c1, c2, d1, d2, e1, e2, f1, f2) {
    if (b1 != "") {
        return abs(a2 - a1) + abs(b2 - b1) + abs(c2 - c1) + abs(d2 - d1) + abs(e2 - e1) + abs(f2 - f1)
    }
    d1 = split(a1, c1, SUBSEP)
    d2 = split(a2, c2, SUBSEP)
    if (d1 > d2) {
        d1 = d2
    }
    e1 = 0
    for (f1 = 1; f1 <= d1; ++f1) {
        e1 += abs(c2[f1] - c1[f1])
    }
    return e1
}

##
# @brief Find the smallest of two numbers.
#
# @param a Number to process
# @param b Number to process
#
# @return Minimum value
#
function min(a, b) { return a < b ? a : b }

##
# @brief Find the largest of two numbers.
#
# @param a Number to process
# @param b Number to process
#
# @return Maximum value
#
function max(a, b) { return a > b ? a : b }

##
# @brief Dump a matrix into a flat string.
#
# @param mat Matrix to convert (2-dimensional, indexed [1,1]-[m,n]
# @param m number of rows (optional, auto-detected if not specified)
# @param n number of columns (optional, auto-detected if not specified)
#
# @return string of form [[row1 separated by commas][row2 ...
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
# @brief Dump a vector into a flat string.
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
# @brief Perform Gaussian elimination on a coefficient matrix and result vector.
#
# The arrays are updated in place, afterward the coefficient vector will be the
# identity matrix and the result vector will contain each coefficient's value.
# Note that for this to succeed, a selected pivot cannot be zero. Since pivots
# are selected along the main diagonal, the first element of the coeffs array
# cannot be 0. Similarly a pair of coefficient rows with a common factor (e.g.,
# 2x + 2y and 3x + 3y) will eventually cause the process to fail. It is up to
# the caller to avoid this (potentially by reorganizing rows/etc.).
#
# @param [in,out] coeffs Coefficient vector indexed [1,1]-[n,n]
# @param [in,out] rhs Results vector indexed [1]-[n]
# @param n number of coeffients (optional, auto-detected in not specified)
#
# @return 1 if successful, 0 if a normalization would result in a divide by 0
#
# @details
#
# Gaussian elimination uses the following process:
# - Move along the main diagonal, selecting each element in turn as the pivot
# - Normalize: divide the pivot row (including rhs) by the pivot value
# - Sweep: For each other row, multiply the pivot row (including rhs) by the
#   the value in the pivot column of the target row and subtract the result
#   from the target row (including rhs).
# - If this process does not fail (e.g., due to a divide by 0), in the end
#   coeffs should become the identity matrix (i.e., 1 along main diagonal,
#   0 elsewhere). At this point the rhs contains the final result vector.
#
# For example, given the set of equations and equivalent matrices:
#
# |  equations  | coeffs | rhs |
# | ----------- | ------ | --- |
# |  x + y = 5  |  1  1  |  5  |
# | 2x - y = 7  |  2 -1  |  7  |
#
# The first pivot value is 1, so normalization simply divides row 1 by 1,
# which changes nothing.
#
# The first sweep subtacts 2 times row 1 ([2 2 | 10]) from row 2, yielding:
#
# |  equations  | coeffs | rhs |
# | ----------- | ------ | --- |
# |  x + y = 5  |  1  1  |  5  |
# |    -3y = -3 |  0 -3  | -3  |
#
# The second and final pivot value is -3, so normalization divides row 2 by
# -3, yielding:
#
# |  equations  | coeffs | rhs |
# | ----------- | ------ | --- |
# |  x + y = 5  |  1  1  |  5  |
# |      y = 1  |  0  1  |  1  |
#
# Sweeping subtracts 1 times row 2 ([0 1 | 1]) from row 1, yielding the
# final result:
#
# |  equations  | coeffs | rhs |
# | ----------- | ------ | --- |
# |  x     = 4  |  1  0  |  4  |
# |      y = 1  |  0  1  |  1  |
#
function gaussianElimination(coeffs, rhs,   n,   i, pivot, j, k, factor) {
    if (!n) {
        n = length(rhs)
    }
    for (i = 1; i <= n; i++) {
        # Select pivot
        pivot = coeffs[i,i]
        if (!pivot) {
            return 0
        }
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
    return 1
}
