#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    FPAT = "[A-D]"
    split("^#{13} ^#\\.{11}# ^###[A-D]#[A-D]#[A-D]#[A-D]### #[A-D]#[A-D]#[A-D]#[A-D]# #{9}", pats)
    split("0 0 4 4 0", flds)
    start = "..........."
    split("1 2 4 6 8 10 11", tmp); for (t in tmp) hallway[tmp[t]] = 1
    deep = 4
    for (i = 1; i <= 4; ++i) for (j = 1; j <= deep; ++j) { bin[2*i+1,j] = 7+i+j*4 }
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
function permute(depth, solution, energy,    hall, wenthome, i, d, apod, adest, allin, d1, d2) {
    if ((solution,energy) in permuted) return
    permuted[solution,energy] = 1
    # print depth, solution, energy > DFILE
    split(solution, hall, "")
    do {
        wenthome = 0
        for (i in hallway) if (hall[i] != ".") {
            apod = hall[i]; adest = dest[apod]
            if (!path_clear(hall, i, adest)) continue
            for (d2 = deep; d2 >= 1; --d2) {
                if (hall[bin[adest,d2]] == ".") {
                    ++wenthome
                    hall[bin[adest,d2]] = apod
                    energy += cost[apod] * dist(i, adest, d2)
                    hall[i] = "."
                    break
                } else if (hall[bin[adest,d2]] != apod) break
            }
        }
        for (d in dest) {
            i = dest[d]
            for (d1 = 1; d1 <= deep; ++d1) {
                apod = hall[bin[i,d1]]
                if (apod != ".") break
            }
            if (apod == d || apod == ".") continue
            adest = dest[apod]
            if (!path_clear(hall, i, adest)) continue
            for (d2 = deep; d2 >= 1; --d2) {
                if (hall[bin[adest,d2]] == ".") {
                    ++wenthome
                    hall[bin[adest,d2]] = apod
                    energy += cost[apod] * dist(i, adest, d1+d2)
                    hall[bin[i,d1]] = "."
                    break
                } else if (hall[bin[adest,d2]] != apod) break
            }
        }
        if (wenthome) {
            allin = 1
            for (apod in dest) for (d1 = 1; d1 <= deep; ++d1) if (hall[bin[dest[apod],d1]] != apod) {
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
    # print depth, move(hall, -1, -1), energy > DFILE

    if (energy >= least) return
    for (apod in dest) {
        adest = dest[apod]
        for (d2 = deep; d2 >= 1; --d2) if (hall[bin[adest,d2]] != apod) break
        for (d1 = 1; d1 <= d2; ++d1) if (hall[bin[adest,d1]] != ".") break
        if (d1 <= d2) for (i in hallway) if (hall[i] == "." && path_clear(hall, adest, i))
            permute(depth+1, move(hall, bin[adest,d1], i), energy + cost[hall[bin[adest,d1]]]*dist(adest,i,d1))
    }
}
END {
    start = substr(start, 1, 15) "DCBADBAC" substr(start, 16)
    permute(1, start, 0)
    print least
}
