#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    FS = ":"
    modulo_conversion = 1
}
(NF == 0) { next }
(NF != 2) {
    aoc::data_error("wrong number of fields")
}
/Monkey [[:digit:]]+:/ {
    if (match($1, /^Monkey ([[:digit:]]+)$/, monkey_name)) {
        m = int(monkey_name[1])
        MONKEYS[m] = 0
    } else {
        aoc::data_error("bad Monkey record")
    }
    next
}
/Starting items:/ {
    n = split($2, starting_items, ", ")
    for (i = 1; i <= n; ++i) {
        ITEMS[0][m][i] = int(starting_items[i])
    }
    next
}
/Operation: new = old \+ [[:digit:]]+/ {
    if (match($2, /new = old \+ ([[:digit:]]+)$/, addend)) {
        MULT[m] = 1
        ADD[m] = int(addend[1])
    } else {
        aoc::data_error("bad addition operation")
    }
    next
}
/Operation: new = old \* [[:digit:]]+/ {
    if (match($2, /new = old \* ([[:digit:]]+)$/, multiplicand)) {
        MULT[m] = int(multiplicand[1])
        ADD[m] = 0
    } else {
        aoc::data_error("bad multiplication operation")
    }
    next
}
/Operation: new = old \* old/ {
    MULT[m] = 0
    ADD[m] = 0
    next
}
/Test:/ {
    if (match($2, /divisible by ([[:digit:]]+)$/, dividend)) {
        TEST[m] = int(dividend[1])
        modulo_conversion *= TEST[m]
    } else {
        aoc::data_error("bad test record")
    }
    next
}
/If true:/ {
    if (match($2, /throw to monkey ([[:digit:]]+)$/, monkey_name)) {
        PASS[m] = int(monkey_name[1])
    } else {
        aoc::data_error("bad test record")
    }
    next
}
/If false:/ {
    if (match($2, /throw to monkey ([[:digit:]]+)$/, monkey_name)) {
        FAIL[m] = int(monkey_name[1])
    } else {
        aoc::data_error("bad test record")
    }
    next
}
{
    aoc::data_error("unknown record type")
}
END {
    if (DEBUG) {
        print "Monkeys:" > DFILE
        for (m in MONKEYS) {
            print m, MULT[m], ADD[m], TEST[m], PASS[m], FAIL[m] > DFILE
        }
        print "Starting items:" > DFILE
        for (m in MONKEYS) {
            printf("%d:", m) > DFILE
            for (i in ITEMS[0][m]) {
                printf(" %d", ITEMS[0][m][i]) > DFILE
            }
            printf("\n") > DFILE
        }
    }
    NUM_ROUNDS = 10000
    for (round = 0; round < NUM_ROUNDS; ++round) {
        next_round = round + 1
        if (DEBUG) {
            print "Round", next_round, ":" > DFILE
        }
        for (m in MONKEYS) {
            split("", ITEMS[next_round][m])
        }
        for (m in MONKEYS) {
            for (i in ITEMS[round][m]) {
                worry = ITEMS[round][m][i]
                if (DEBUG) {
                    print "monkey", m, "inspects item with worry level", worry > DFILE
                }
                ++MONKEYS[m]
                multiplier = MULT[m] ? MULT[m] : worry
                worry = worry * multiplier + ADD[m]
                # print "worry level changes to", worry > DFILE
                worry = worry % modulo_conversion
                n = (worry % TEST[m]) ? FAIL[m] : PASS[m]
                if (DEBUG) {
                    print "tosses item with worry level", worry, "to monkey", n > DFILE
                }
                dest_round = n > m ? round : next_round;
                ITEMS[dest_round][n][length(ITEMS[dest_round][n])+1] = worry
            }
        }
        if (DEBUG) {
            for (m in MONKEYS) {
                printf("%d (%d):", m, MONKEYS[m]) > DFILE
                for (i in ITEMS[next_round][m]) {
                    printf(" %d", ITEMS[next_round][m][i]) > DFILE
                }
                printf("\n") > DFILE
            }
        }
    }

    # for (m in MONKEYS) {
    #     printf("%d:", m) > DFILE
    #     for (i in ITEMS[NUM_ROUNDS][m]) {
    #         printf(" %d", ITEMS[NUM_ROUNDS][m][i]) > DFILE
    #     }
    #     printf("\n") > DFILE
    #     LENS[m] = length(ITEMS[NUM_ROUNDS][m])
    # }
    # asorti(LENS, LONGEST, "@val_num_desc")
    # print "longest:", LENS[LONGEST[1]], LENS[LONGEST[2]] > DFILE
    # print "by monkeys:", LONGEST[1], LONGEST[2] > DFILE

    asorti(MONKEYS, LONGEST, "@val_num_desc")
    # print "longest:", MONKEYS[LONGEST[1]], MONKEYS[LONGEST[2]] > DFILE
    # print "by monkeys:", LONGEST[1], LONGEST[2] > DFILE
    print MONKEYS[LONGEST[1]] * MONKEYS[LONGEST[2]]
}
