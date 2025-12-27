#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    FS = ""
    directions["E"] = directions["S"] = directions["W"] = directions["N"] = 1
    EVEN = 0
    ODD = 1
    DEBUG = 0
}
$0 !~ /^[.#S]+$/ {
    aoc::data_error()
}
!width { width = NF }
(width != NF) {
    aoc::data_error("saw width " NF ", expected " width)
}
{
    for (c = 1; c <= NF; ++c) {
        switch ($c) {
            case "S":
                startx = c - 1
                starty = NR - 1
                STEPS[0][startx,starty] = 1
                VISITED[EVEN][startx,starty] = 1
            case ".":
                GARDEN[(c - 1),(NR - 1)] = 1
                break
            case "#":
                break
            default:
                aoc::data_error("unexpected code " $c)
        }
    }
}
function move(from, dir,   coords) {
    split(from, coords, SUBSEP)
    switch (dir) {
        case "E":
            return ((coords[1] + 1) SUBSEP coords[2])
        case "S":
            return (coords[1] SUBSEP (coords[2] + 1))
        case "W":
            return ((coords[1] - 1) SUBSEP coords[2])
        case "N":
            return (coords[1] SUBSEP (coords[2] - 1))
        default:
            aoc::compute_error("unknown direction " dir)
    }
}
function mod(n,   m, result) {
    result = n % m
    return (result >= 0) ? result : result + m
}
function normalize(from,   coords) {
    split(from, coords, SUBSEP)
    return mod(coords[1], size) SUBSEP mod(coords[2], size)
}
function stringize(from,   coords) {
    split(from, coords, SUBSEP)
    return "(" ((coords[1] + 0) % size) "," ((coords[2] + 0) % size) ")"
}
function dump(distance,   x, y, coords) {
    for (y = starty - distance; y <= starty + distance; ++y) {
        for (x = startx - distance; x <= startx + distance; ++x) {
            coords = x SUBSEP y
            if (coords in STEPS[0]) {
                printf "S" > DFILE
            } else if (coords in VISITED[EVEN]) {
                printf "E" > DFILE
            } else if (coords in VISITED[ODD]) {
                printf "O" > DFILE
            } else if (normalize(coords) in GARDEN) {
                printf "." > DFILE
            } else {
                printf "#" > DFILE
            }
        }
        printf "\n" > DFILE
    }
}
END {
    if (width != NR) {
        aoc::compute_error("cannot handle width " width " != size " NR)
    }
    if (!length(STEPS[0])) {
        aoc::compute_error("no starting position found")
    }
    size = width
    if (size < 12) {
        num_steps = 5000
    } else {
        num_steps = 26501365
    }
    fx_stride = 2 * size
    x = 0
    fx0 = fx = num_steps % fx_stride
    xtarget = (num_steps - fx0) / fx_stride
    if (DEBUG) {
        print "target x =", xtarget > DFILE
        print "fx0 =", fx0 > DFILE
        print "fx_stride =", fx_stride > DFILE
    }
    # figure out where the quadratic relationship begins
    for (step = 0; step <= num_steps; ++step) {
        parity = step % 2
        parity_next = !parity
        for (pos in STEPS[step]) {
            for (dir in directions) {
                new_pos = move(pos, dir)
                if (!(new_pos in VISITED[parity_next]) && ((normalize(new_pos) in GARDEN))) {
                    if (new_pos in VISITED[parity]) {
                        aoc::compute_error(stringize(new_pos) "found in parity " parity " when adding to " parity_next)
                    }
                    STEPS[step + 1][new_pos] = 1
                    VISITED[parity_next][new_pos] = 1
                }
            }
        }
        if (step > fx) {
            aoc::compute_error("step " step " passed threshold " fx)
        }
        if (step == fx) {
            F[x] = length(VISITED[parity])
            if (DEBUG > 1) {
                print "F[" x "] = " F[x] > DFILE
            }
            if ((x - 1) in F) {
                DF[x] = F[x] - F[x - 1]
                if (DEBUG > 1) {
                    print "DF[" x "] = " DF[x] > DFILE
                }
                if ((x - 1) in DF) {
                    DDF[x] = DF[x] - DF[x - 1]
                    if (DEBUG > 1) {
                        print "DDF[" x "] = " DDF[x] > DFILE
                    }
                    if (((x - 2) in DDF) && (DDF[x - 2] == DDF[x - 1])) {
                        if (DEBUG) {
                            print "DDF[" x "] matched at", DDF[x] > DFILE
                        }
                        if (DDF[x] != DDF[x - 1]) {
                            aoc::compute_error("DDF[x] != DDF[x-1]")
                        }
                        break
                    }
                }
            }
            fx += fx_stride
            ++x
        }
    }
    if (step > num_steps) {
        --x
    }

    a = (F[x] - 2 * F[x-1] + F[x-2]) / (x^2 - 2*(x-1)^2 + (x-2)^2)
    b = (F[x] - F[x-1]) - (x^2 - (x-1)^2) * a
    c = F[x] - x^2 * a - x * b

    if (DEBUG) {
        print a, "x^2 +", b, "x +", c > DFILE
    }

    print a * xtarget ^ 2 + b * xtarget + c
}
