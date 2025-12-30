#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
(NF != 1 || $1 !~ /^".*"$/ || $1 ~ /[^\\]"./ ) { aoc::data_error() }
{
    literals += length()
    $0 = substr($0, 2, length() - 2)
    gsub(/\\\\/, "@")
    gsub(/\\x../, "@")
    gsub(/\\"/, "@")
    memory += length()
}
END {
    print literals - memory
}
