#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    valid_passphrases = 0
}
function set_all_permutations_from(WORDS, start, REST,   letter, l, REMAINING) {
    if (length(REST) == 0) {
        WORDS[start] = 1
        return
    }
    split("", REMAINING)
    for (letter in REST) {
        REMAINING[letter] = REST[letter]
    }
    for (letter in REST) {
        delete REMAINING[letter]
        set_all_permutations_from(WORDS, start REST[letter], REMAINING)
        REMAINING[letter] = REST[letter]
    }
}
function set_all_permutations(WORDS, word,   WORD) {
    split(word, WORD, "")
    set_all_permutations_from(WORDS, "", WORD)
}
{
    split("", WORDS)
    valid = 1
    for (i = 1; i <= NF; ++i) {
        if ($i in WORDS) {
            valid = 0
            break
        } else {
            set_all_permutations(WORDS, $i)
        }
    }
    valid_passphrases += valid
}
END {
    print valid_passphrases
}
