#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
(NF != 1 || $1 !~ /^".*"$/ || $1 ~ /[^\\]"./ ) { aoc::data_error() }
{
    literals += length()
    gsub(/\\/, "\\\\")
    gsub(/"/, "\\\"")
    $0 = "\"" $0 "\""
    encoded += length()
}
END {
    print encoded - literals
}
