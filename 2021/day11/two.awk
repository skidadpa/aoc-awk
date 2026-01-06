#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
( NF != 1 || length($1) != 10 ) { aoc::data_error() }
{ split($1, row, ""); for (x = 1; x <= 10; ++x) octopi[x,NR] = row[x] }
function increase_energy(octopi, flashing, x, y) { if (++octopi[x,y] > 9) flashing[x,y] = 1 }
function step(octopi,    flashes, flashing, flashed, x, y, o, done) {
    split("", flashing)
    split("", flashed)
    for (y = 1; y <= 10; ++y) for (x = 1; x <= 10; ++x) increase_energy(octopi, flashing, x, y)
    do {
        done = 1
        for (o in flashing) if (!(o in flashed)) {
            split(o, tmp, SUBSEP); x = tmp[1]; y = tmp[2]
            if (x > 1) {
                if (y > 1) increase_energy(octopi, flashing, x-1, y-1)
                increase_energy(octopi, flashing, x-1, y)
                if (y < 10) increase_energy(octopi, flashing, x-1, y+1)
            }
            if (y > 1) increase_energy(octopi, flashing, x, y-1)
            if (y < 10) increase_energy(octopi, flashing, x, y+1)
            if (x < 10) {
                if (y > 1) increase_energy(octopi, flashing, x+1, y-1)
                increase_energy(octopi, flashing, x+1, y)
                if (y < 10) increase_energy(octopi, flashing, x+1, y+1)
            }
            flashed[o] = ++flashes
            done = 0
        }
    } while (!done)
    for (o in flashed) octopi[o] = 0
    return flashes
}
END {
    if (NR != 10) { aoc::data_error() }
    for (i = 1; i <= 10000; ++i) if (step(octopi) > 99) { print i; exit 0 }
    aoc::compute_error()
}
