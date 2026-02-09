#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
function dump(   x, y, coords, cart) {
    for (y = 0; y < HEIGHT; ++y) {
        for (x = 0; x < WIDTH; ++x) {
            coords = x SUBSEP y
            if (coords in CRASH) {
                printf "X" > DFILE
            } else if (coords in CARTS) {
                cart = CARTS[coords]
                printf "%s", ICON[DX[cart],DY[cart]] > DFILE
            } else if (coords in TURNS) {
                printf "%s", TURNS[x,y] > DFILE
            } else if (coords in PATHS) {
                printf "%s", PATHS[x,y] > DFILE
            } else if (coords in INTERSECTIONS) {
                printf "%s", INTERSECTIONS[x,y] > DFILE
            } else {
                printf " " > DFILE
            }
        }
        printf "\n" > DFILE
    }
    if (DEBUG > 4) {
        print "carts:" > DFILE
        for (coords in CARTS) {
            cart = CARTS[coords]
            printf "%s at [%d,%d]\n", ICON[DX[cart],DY[cart]], X[cart], Y[cart] > DFILE
        }
    }
}
function select_turn(cart) {
    if (DEBUG > 3) {
        printf "TURNING CART: %d,%d,%d -> ", TURN_TYPE[cart], DX[cart], DY[cart] > DFILE
    }

    switch (TURN_TYPE[cart]) {
    case 0:
        # left
        if (DX[cart] == -1) {
            DX[cart] = 0
            DY[cart] = 1
        } else if (DX[cart] == 1) {
            DX[cart] = 0
            DY[cart] = -1
        } else if (DY[cart] == -1) {
            DX[cart] = -1
            DY[cart] = 0
        } else if (DY[cart] == 1) {
            DX[cart] = 1
            DY[cart] = 0
        } else {
            aoc::compute_error("illegal DX/DY combo: " DX[cart] "," DY[cart])
        }
        break
    case 1:
        break
    case 2:
        # right
        if (DX[cart] == -1) {
            DX[cart] = 0
            DY[cart] = -1
        } else if (DX[cart] == 1) {
            DX[cart] = 0
            DY[cart] = 1
        } else if (DY[cart] == -1) {
            DX[cart] = 1
            DY[cart] = 0
        } else if (DY[cart] == 1) {
            DX[cart] = -1
            DY[cart] = 0
        } else {
            aoc::compute_error("illegal DX/DY combo: " DX[cart] "," DY[cart])
        }
        break
    default:
        aoc::compute_error("illegal turn type " TURN_TYPE[cart])
    }
    ++TURN_TYPE[cart]
    TURN_TYPE[cart] %= 3

    if (DEBUG > 3) {
        printf "%d,%d,%d\n", TURN_TYPE[cart], DX[cart], DY[cart] > DFILE
    }
}
BEGIN {
    FS = ""
    PROCINFO["sorted_in"] = "@ind_num_asc"
    MAP_DX["<"] = -1
    MAP_DX[">"] = 1
    MAP_DX["v"] = 0
    MAP_DX["^"] = 0
    MAP_DY["<"] = 0
    MAP_DY[">"] = 0
    MAP_DY["v"] = 1
    MAP_DY["^"] = -1
    ICON[-1,0] = "<"
    ICON[1,0] = ">"
    ICON[0,-1] = "^"
    ICON[0,1] = "v"
    ICON["",""] = ICON[0,0] = ICON[1,1] = ICON[-1,-1] = ICON[1,-1] = ICON[-1,1] = "?"
    if (DEBUG) {
        split("", CRASH)
    }
}
$0 ~! /^[/\\-|+<>v^ ]+$/ { aoc::data_error() }
{
    if (WIDTH == "") {
        WIDTH = NF
    }
    if (WIDTH != NF) {
        aoc::data_error("width changed from " WIDTH " to " NF)
    }
    y = NR - 1
    for (i = 1; i <= NF; ++i) {
        x = i - 1
        switch ($i) {
        case "/":
        case "\\":
            TURNS[x,y] = $i
            break
        case "-":
        case "|":
            PATHS[x,y] = $i
            break
        case "+":
            INTERSECTIONS[x,y] = $i
            break
        case "<":
        case ">":
        case "v":
        case "^":
            cart = x SUBSEP y
            ALL_CARTS[y * WIDTH + x] = cart
            X[cart] = x
            Y[cart] = y
            DX[cart] = MAP_DX[$i]
            DY[cart] = MAP_DY[$i]
            CARTS[x,y] = cart
            PATHS[x,y] = (DX[cart] == 0) ? "|" : "-"
            TURN_TYPE[x,y] = 0
            break
        case " ":
            break
        default:
            aoc::data_error("unknown element type " $i)
        }
    }
}
END {
    HEIGHT = NR
    if (DEBUG) {
        print "at beginning,", length(CARTS), "carts" > DFILE
        if (DEBUG > 1) {
            dump()
        }
    }
    if (length(ALL_CARTS) % 2 == 0) {
        aoc::data_error("number of carts must be odd, there are " length(ALL_CARTS))
    }
    TIME_LIMIT = 1000000
    for (t = 1; t <= TIME_LIMIT; ++t) {
        for (c in ALL_CARTS) {
            cart = ALL_CARTS[c]
            if (!(cart in X)) {
                continue
            }
            x = X[cart]
            y = Y[cart]
            delete CARTS[x,y]
            x += DX[cart]
            y += DY[cart]
            X[cart] = x
            Y[cart] = y
            coords = x SUBSEP y
            if (coords in CARTS) {
                delete X[CARTS[x,y]]
                delete Y[CARTS[x,y]]
                delete CARTS[x,y]
                delete X[cart]
                delete Y[cart]
                if (DEBUG) {
                    printf "crash at [%d,%d] at step %d, %d carts left\n", x, y, t, length(CARTS) > DFILE
                    if (length(CARTS) < 2) {
                        for (cc in CARTS) {
                            printf "remaining cart is at %d,%d\n", X[CARTS[cc]], Y[CARTS[cc]] > DFILE
                        }
                    }
                }
                if (DEBUG > 1) {
                    CRASH[x,y] = 1
                    dump()
                    delete CRASH[x,y]
                }
                continue
            }
            if (coords in TURNS) {
                switch (TURNS[x,y]) {
                case "/":
                    tmp = DY[cart]
                    DY[cart] = -DX[cart]
                    DX[cart] = -tmp
                    break
                case "\\":
                    tmp = DY[cart]
                    DY[cart] = DX[cart]
                    DX[cart] = tmp
                    break
                default:
                    aoc::compute_error("unknown turn type " TURNS[x,y])
                }
            } else if (coords in INTERSECTIONS) {
                select_turn(cart)
            }
            CARTS[x,y] = cart
        }
        if (length(CARTS) < 2) {
            if (DEBUG) {
                print "ended at step", t, "with one cart left" > DFILE
            }
            for (c in CARTS) {
                cart = CARTS[c]
                printf "%d,%d\n", X[cart], Y[cart]
            }
            exit
        }
        split("", ALL_CARTS)
        for (c in CARTS) {
            cart = CARTS[c]
            ALL_CARTS[Y[cart] * WIDTH + X[cart]] = cart
        }

        if (DEBUG > 2) {
            print "after", t, "steps" > DFILE
            dump()
        }
    }
    aoc::compute_error("ran out of collisions after " TIME_LIMIT " steps")
}
