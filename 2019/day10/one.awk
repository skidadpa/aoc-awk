#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"

BEGIN {
    FS = ""
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
function blocked_by(ax, ay, ox, oy,   x, y, x0, x1, xd, y0, y1, yd, gcd) {
    if (ax == ox) {
        for (y = aoc::min(ay,oy) + 1; y < aoc::max(ay,oy); ++y) {
            if ((ax SUBSEP y) in ASTEROIDS) {
                return "BLOCKED vertically BY [" ax "," y "]"
            }
        }
    } else if (ay == oy) {
        for (x = aoc::min(ax,ox) + 1; x < aoc::max(ax,ox); ++x) {
            if ((x SUBSEP ay) in ASTEROIDS) {
                return "BLOCKED horizontally BY [" x "," ay "]"
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
    return "not blocked"
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
    if (DEBUG) {
        split(a, coeff, SUBSEP)
        ax = coeff[1]
        ay = coeff[2]
        printf "best of %d asteroids is at [%d,%d]:\n", length(ASTEROIDS), ax, ay > DFILE
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
        if (DEBUG > 9) {
            PROCINFO["sorted_in"] = "@ind_str_asc"
            for (o in ASTEROIDS) if (o != a) {
                split(o, coeff, SUBSEP)
                ox = coeff[1]
                oy = coeff[2]
                printf " [%d,%d]: %s\n", ox, oy, blocked_by(ax,ay,ox,oy) > DFILE
            }
        }
    }
    print ASTEROIDS[a]
}
