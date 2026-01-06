#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    FPAT = "[A-D]"
    split("^#{13} ^#\\.{11}# ^###[A-D]#[A-D]#[A-D]#[A-D]### #[A-D]#[A-D]#[A-D]#[A-D]# #{9}", pats)
    split("0 0 4 4 0", flds)
    start = "..........."
    split("1 2 4 6 8 10 11", tmp); for (t in tmp) hallway[tmp[t]] = 1
    for (i = 1; i <= 4; ++i) { top[2*i+1] = 11+i; bot[2*i+1] = 15+i }
    dest["A"] = 3; dest["B"] = 5; dest["C"] = 7; dest["D"] = 9
    cost["A"] = 1; cost["B"] = 10; cost["C"] = 100; cost["D"] = 1000
    least = 999999999
}
(NR > 5 || $0 !~ pats[NR] "$" || NF != flds[NR]) { aoc::data_error() }
(NF == 4) { start = start $1 $2 $3 $4 }
function dist(a,b,plus) { return a+0 > b+0 ? plus + a - b : plus + b - a }
function path_clear(hall, b, h,    i, dir) {
    dir = h+0 > b+0 ? 1 : -1
    for (i = b + dir; i != h; i += dir) if (hall[i] != ".") return 0
    return 1
}
function move(spaces, from, to,    result, i)
{
    result = ""
    for (i in spaces) {
        if (i == to) result = result spaces[from]
        else if (i == from) result = result "."
        else result = result spaces[i]
    }
    return result
}
function permute(depth, solution, energy,    hall, wenthome, i, apod, adest, allin) {
    if ((solution,energy) in permuted) return
    permuted[solution,energy] = 1
    # print depth, solution, energy > DFILE
    split(solution, hall, "")
    do {
        wenthome = 0
        for (i in hallway) if (hall[i] != ".") {
            apod = hall[i]; adest = dest[apod]
            if (hall[bot[adest]] == ".") {
                if (!path_clear(hall, i, adest)) continue
                ++wenthome
                hall[bot[adest]] = apod
                energy += cost[apod] * dist(i, adest, 2)
                hall[i] = "."
            } else if (hall[bot[adest]] == apod && hall[top[adest]] == ".") {
                if (!path_clear(hall, i, adest)) continue
                ++wenthome
                hall[top[adest]] = apod
                energy += cost[apod] * dist(i, adest, 1)
                hall[i] = "."
            }
        }
        for (i in dest) {
            apod = hall[top[dest[i]]]
            if (apod == i) continue
            if (apod == ".")  {
                apod = hall[bot[dest[i]]]
                if (apod == i || apod == ".")  continue
                adest = dest[apod]
                if (hall[bot[adest]] == ".") {
                    if (!path_clear(hall, dest[i], adest)) continue
                    ++wenthome
                    hall[bot[adest]] = apod
                    energy += cost[apod] * dist(dest[i], adest, 4)
                    hall[bot[dest[i]]] = "."
                } else if (hall[bot[adest]] == apod && hall[top[adest]] == ".") {
                    if (!path_clear(hall, dest[i], adest)) continue
                    ++wenthome
                    hall[top[adest]] = apod
                    energy += cost[apod] * dist(dest[i], adest, 3)
                    hall[bot[dest[i]]] = "."
                }
            } else {
                adest = dest[apod]
                if (hall[bot[adest]] == ".") {
                    if (!path_clear(hall, dest[i], adest)) continue
                    ++wenthome
                    hall[bot[adest]] = apod
                    energy += cost[apod] * dist(dest[i], adest, 3)
                    hall[top[dest[i]]] = "."
                } else if (hall[bot[adest]] == apod && hall[top[adest]] == ".") {
                    if (!path_clear(hall, dest[i], adest)) continue
                    ++wenthome
                    hall[top[adest]] = apod
                    energy += cost[apod] * dist(dest[i], adest, 2)
                    hall[top[dest[i]]] = "."
                }
            }
        }
        if (wenthome) {
            allin = 1
            for (apod in dest) if (hall[top[dest[apod]]] != apod || hall[bot[dest[apod]]] != apod) {
                allin = 0
                break
            }
            if (allin) {
                if (energy < least) least = energy
                # print depth, move(hall, -1, -1), energy, "ALL IN" > DFILE
                return
            }
        }
    } while (wenthome)
    # print depth, move(hall, -1, -1), energy

    if (energy >= least) return
    for (apod in dest) {
        adest = dest[apod]
        if (hall[top[adest]] == ".") {
            if (hall[bot[adest]] != "." && hall[bot[adest]] != apod)
                for (i in hallway) if (hall[i] == "." && path_clear(hall, adest, i))
                    permute(depth+1, move(hall, bot[adest], i), energy + cost[hall[bot[adest]]]*dist(adest,i,2))
        } else {
            if (hall[top[adest]] != apod || hall[bot[adest]] != apod)
                for (i in hallway) if (hall[i] == "." && path_clear(hall, adest, i))
                    permute(depth+1, move(hall, top[adest], i), energy + cost[hall[top[adest]]]*dist(adest,i,1))
        }
    }
}
END {
    permute(1, start, 0)
    print least
}
