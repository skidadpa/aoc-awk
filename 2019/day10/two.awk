#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"

BEGIN {
    FS = ""
    PI = atan2(0, -1)
}

$0 !~ /^[.#]+$/ { aoc::data_error() }
!(WIDTH) {
    WIDTH = NF
}
(WIDTH != NF) {
    aoc::data_error("width changed from " WIDTH " to " NF)
}
{
    for (i = 1; i <= NF; ++i) {
        if ($i == "#") {
            x = i - 1
            y = NR - 1
            ASTEROIDS[x,y] = 0
        }
    }
}
function blocked(ax, ay, ox, oy,   x, y, x0, x1, xd, y0, y1, yd, gcd) {
    if (ax == ox) {
        for (y = aoc::min(ay,oy) + 1; y < aoc::max(ay,oy); ++y) {
            if ((ax SUBSEP y) in ASTEROIDS) {
                return 1
            }
        }
    } else if (ay == oy) {
        for (x = aoc::min(ax,ox) + 1; x < aoc::max(ax,ox); ++x) {
            if ((x SUBSEP ay) in ASTEROIDS) {
                return 1
            }
        }
    } else {
        x0 = aoc::min(ax,ox)
        x1 = aoc::max(ax,ox)
        xd = x1 - x0
        y0 = aoc::min(ay,oy)
        y1 = aoc::max(ay,oy)
        yd = y1 - y0
        for (gcd = aoc::min(xd, yd); gcd > 1; --gcd) {
            if (!(xd % gcd) && !(yd % gcd)) {
                break
            }
        }
        if (gcd > 1) {
            xd = (ox - ax) / gcd
            yd = (oy - ay) / gcd
            x = ax + xd
            y = ay + yd
            while (x != ox) {
                if ((x SUBSEP y) in ASTEROIDS) {
                    return "BLOCKED with gcd " gcd " at stride [" xd "," yd "] BY [" x "," y "]"
                }
                x += xd
                y += yd
            }
        }
    }
    return 0
}
function compute_angle(dx, dy,   a) {
    a = atan2(dx, dy)
    if (a < 0) {
        a += 2 * PI
    }
    return a
}
function find_initial_angles(ax, ay, o,   coeff, ox, oy, x, y, x0, x1, xd, y0, y1, yd, gcd, angle) {
    split(o, coeff, SUBSEP)
    ox = coeff[1]
    oy = coeff[2]
    if (ax == ox) {
        yd = (ay < oy) ? -1 : 1
        for (y = oy + yd; y != ay; y += yd) {
            if ((ax SUBSEP y) in ASTEROIDS) {
                BLOCKED_BY[ax,y] = o
                if (DEBUG > 3) {
                    printf "   [%d,%d] blocks [%d,%d]\n", ax, y, ox, oy > DFILE
                }
                return
            }
        }
    } else if (ay == oy) {
        xd = (ax < ox) ? -1 : 1
        for (x = ox + xd; x != ax; x += xd) {
            if ((x SUBSEP ay) in ASTEROIDS) {
                BLOCKED_BY[x,ay] = o
                if (DEBUG > 3) {
                    printf "   [%d,%d] blocks [%d,%d]\n", x, ay, ox, oy > DFILE
                }
                return
            }
        }
    } else {
        x0 = aoc::min(ax,ox)
        x1 = aoc::max(ax,ox)
        xd = x1 - x0
        y0 = aoc::min(ay,oy)
        y1 = aoc::max(ay,oy)
        yd = y1 - y0
        for (gcd = aoc::min(xd, yd); gcd > 1; --gcd) {
            if (!(xd % gcd) && !(yd % gcd)) {
                break
            }
        }
        if (gcd > 1) {
            xd = (ax - ox) / gcd
            yd = (ay - oy) / gcd
            x = ox + xd
            y = oy + yd
            while (x != ax) {
                if ((x SUBSEP y) in ASTEROIDS) {
                    BLOCKED_BY[x,y] = o
                    if (DEBUG > 3) {
                        printf "   [%d,%d] blocks [%d,%d]\n", x, y, ox, oy > DFILE
                    }
                    return
                }
                x += xd
                y += yd
            }
        }
    }
    angle = compute_angle(ox - ax, ay - oy)
    ANGLES[1][angle] = o
    if (DEBUG > 3) {
        printf "%f: [%d,%d]\n", angle, ox, oy > DFILE
    }
}
END {
    HEIGHT = NR
    for (a in ASTEROIDS) {
        split(a, coeff, SUBSEP)
        ax = coeff[1]
        ay = coeff[2]
        for (o in ASTEROIDS) if (o != a) {
            split(o, coeff, SUBSEP)
            ox = coeff[1]
            oy = coeff[2]
            if (!blocked(ax, ay, ox, oy)) {
                ++ASTEROIDS[a]
            }
        }
    }
    PROCINFO["sorted_in"] = "@val_num_desc"
    for (a in ASTEROIDS) {
        break
    }
    PROCINFO["sorted_in"] = "@unsorted"
    split(a, coeff, SUBSEP)
    ax = coeff[1]
    ay = coeff[2]
    if (DEBUG) {
        printf "best of %d asteroids is at [%d,%d]\n", length(ASTEROIDS), ax, ay > DFILE
        if (DEBUG > 1) {
            for (y = 0; y < HEIGHT; ++y) {
                for (x = 0; x < WIDTH; ++x) {
                    if ((x == ax) && (y == ay)) {
                        printf "O" > DFILE
                    } else if ((x SUBSEP y) in ASTEROIDS) {
                        if (blocked(ax, ay, x, y)) {
                            printf "x" > DFILE
                        } else {
                            printf "#" > DFILE
                        }
                    } else {
                        printf "." > DFILE
                    }
                }
                printf "\n" > DFILE
            }
        }
    }
    split("", BLOCKED_BY)
    for (o in ASTEROIDS) if (o != a) {
        find_initial_angles(ax,ay,o)
    }
    PROCINFO["sorted_in"] = "@ind_num_asc"
    COUNT = 0
    ITERATION = 1
    while (ITERATION in ANGLES) {
        if (DEBUG > 3) {
            print "ITERATION:", ITERATION > DFILE
        }
        for (angle in ANGLES[ITERATION]) {
            o = ANGLES[ITERATION][angle]
            ++COUNT
            if (DEBUG > 1) {
                split(o, coeff, SUBSEP)
                ox = coeff[1]
                oy = coeff[2]
                printf " %d: destroyed asteroid at %f:[%d,%d]\n", COUNT, angle, ox, oy > DFILE
            }
            if (COUNT == 200) {
                split(o, coeff, SUBSEP)
                ox = coeff[1]
                oy = coeff[2]
                print ox * 100 + oy
                exit
            }
            if (o in BLOCKED_BY) {
                split(BLOCKED_BY[o], coeff, SUBSEP)
                ox = coeff[1]
                oy = coeff[2]
                new_angle = compute_angle(ox - ax, ay - oy)
                if (DEBUG > 3) {
                    printf "%f: [%d,%d]\n", new_angle, ox, oy > DFILE
                }
                ANGLES[ITERATION + 1][new_angle] = BLOCKED_BY[o]
            }
        }
        ++ITERATION
    }
    aoc::compute_error("ran out of asteroids after " COUNT ", did not reach 200")
}
