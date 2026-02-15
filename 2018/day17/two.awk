#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
function dump(   y, x, coords) {
    if (VISUAL_DEBUG) {
        aoc::home_cursor(DFILE)
    }
    for (y = 1; y <= length(XMAX); ++y) {
        printf "      " > DFILE
        for (x = XMIN; x <= XMAX; ++x) {
            printf "%s", substr(x, y, 1) > DFILE
        }
        printf "\n" > DFILE
    }
    for (y = YMIN; y <= YMAX; ++y) {
        printf "%04d : ", y > DFILE
        for (x = XMIN; x <= XMAX; ++x) {
            coords = (x SUBSEP y)
            if (coords in CLAY) {
                printf "#" > DFILE
            } else if (coords in SAND) {
                printf "." > DFILE
            } else if (coords in RUNNING_WATER) {
                printf "|" > DFILE
            } else if (coords in STANDING_WATER) {
                printf "~" > DFILE
            } else if (coords in SPRING) {
                printf "+" > DFILE
            } else {
                aoc::compute_error("[" x "," y "] in unknown state")
            }
        }
        printf "\n" > DFILE
    }
    if (VISUAL_DEBUG) {
        printf "\n" > DFILE
        system(SLEEP)
    }
}
function mark(coords, state) {
    state[coords] = 1
    delete SAND[coords]
    if (DEBUG > 1) {
        dump()
    }
}
function convert_water(coords) {
    STANDING_WATER[coords] = 1
    delete RUNNING_WATER[coords]
    if (DEBUG > 1) {
        dump()
    }
}
function left(coords,  c) {
    split(coords, c, SUBSEP)
    return ((c[1] - 1) SUBSEP c[2])
}
function right(coords,  c) {
    split(coords, c, SUBSEP)
    return ((c[1] + 1) SUBSEP c[2])
}
function down(coords,  c) {
    split(coords, c, SUBSEP)
    return (c[1] SUBSEP (c[2] + 1))
}
function descend(coords, spread_directions,   c, spreading) {
    c = down(coords)
    if (c in SAND) {
        mark(c, RUNNING_WATER)
        spreading = descend(c, SPREAD_BOTH)
    } else if (!(c in RUNNING_WATER)) {
        spreading = (c in REGION)
    }

    if (spreading) {
        if (and(spread_directions, SPREAD_LEFT)) {
            c = left(coords)
            if (c in RUNNING_WATER) {
                aoc::compute_error("no support for spreading into water yet")
            }
            if (c in SAND) {
                mark(c, RUNNING_WATER)
                spreading = descend(c, SPREAD_LEFT)
            }
        }
        if (and(spread_directions, SPREAD_RIGHT)) {
            c = right(coords)
            if (c in RUNNING_WATER) {
                aoc::compute_error("no support for spreading into water yet")
            }
            if (c in SAND) {
                mark(c, RUNNING_WATER)
                if (spreading) {
                    spreading = descend(c, SPREAD_RIGHT)
                } else {
                    descend(c, SPREAD_RIGHT)
                }
            }
        }
        if (spreading && (spread_directions == SPREAD_BOTH)) {
            if (coords in RUNNING_WATER) {
                convert_water(coords)
            }
            c = left(coords)
            while (c in RUNNING_WATER) {
                convert_water(c)
                c = left(c)
            }
            c = right(coords)
            while (c in RUNNING_WATER) {
                convert_water(c)
                c = right(c)
            }
        }
    }
    return spreading
}
BEGIN {
    FPAT = "[[:digit:]]+"
    YMIN = 99999999
    YMAX = 0
    XMIN = 500
    XMAX = 500
    SPREAD_LEFT = 1
    SPREAD_RIGHT = 2
    SPREAD_BOTH = 3
    if (VISUAL_DEBUG) {
        DEBUG = VISUAL_DEBUG
        SLEEP = "sleep 0.01"
        aoc::clear_screen(DFILE)
    }
}
(NF != 3) || ($2 > $3) { aoc::data_error("did not get a number plus a valid range") }
/^x=[[:digit:]]+, y=[[:digit:]]+[.]{2}[[:digit:]]+$/ {
    if (XMAX < $1) {
        XMAX = $1
    }
    if (XMIN > $1) {
        XMIN = $1
    }
    if (YMIN > $2) {
        YMIN = $2
    }
    if (YMAX < $3) {
        YMAX = $3
    }
    x = $1
    for (y = $2; y <= $3; ++y) {
        CLAY[x,y] = 1
    }
    next
}
/^y=[[:digit:]]+, x=[[:digit:]]+[.]{2}[[:digit:]]+$/ {
    if (YMIN > $1) {
        YMIN = $1
    }
    if (YMAX < $1) {
        YMAX = $1
    }
    if (XMIN > $2) {
        XMIN = $2
    }
    if (XMAX < $3) {
        XMAX = $3
    }
    y = $1
    for (x = $2; x <= $3; ++x) {
        CLAY[x,y] = 1
    }
    next
}
{ aoc::data_error() }
END {
    --XMIN
    ++XMAX
    for (x = XMIN; x <= XMAX; ++x) for (y = YMIN; y <= YMAX; ++y) {
        if (!((x SUBSEP y) in CLAY)) {
            SAND[x,y] = 1
        }
        REGION[x,y] = 1
    }
    SPRING[500,YMIN - 1] = 1
    if (DEBUG) {
        dump()
        printf "\n[%d,%d] - [%d,%d]\n", XMIN, YMIN, XMAX, YMAX > DFILE
    }
    for (coords in SPRING) {
        descend(coords, SPREAD_BOTH)
    }
    if (DEBUG) {
        dump()
    }
    print length(STANDING_WATER)
}
