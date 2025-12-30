#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
function next_token(    tok) {
    if (currchar > nchars) { aoc::compute_error("ERROR 1") }
    tok = chars[currchar++]
    switch (tok) {
    case /[-0-9]/:
        while (chars[currchar] ~ /[0-9]/) tok = tok chars[currchar++]
        return tok+0
    case "\"":
        tok = ""
        while (chars[currchar] != "\"") tok = tok chars[currchar++]
        ++currchar
        return (tok == "red") ? "RED" : "STR"
    case /[\[\{\]\},:]/:
        return tok
    default:
        aoc::compute_error("ERROR 2")
    }
}
function parse(token,    sum, red)
{
    if (token == "{") {
        if (chars[currchar] == "}") {
            next_token()
            return 0
        }
        while (token != "}") {
            token = next_token()
            if (token != "STR" && token != "RED") { aoc::compute_error("ERROR 3") }
            token = next_token()
            if (token != ":") { aoc::compute_error("ERROR 4") }
            token = next_token()
            switch (token) {
            case /[\[\{]/:
                sum += parse(token)
                break
            case /[-0-9]+/:
                sum += token
                break
            case "STR":
                break
            case "RED":
                red = 1
                break
            default:
                aoc::compute_error("ERROR 5")
            }
            token = next_token()
            if (token ~ /,\}/) { aoc::compute_error("ERROR 6") }
        }
        return red ? 0 : sum+0
    } else if (token == "[") {
        if (chars[currchar] == "]") {
            next_token()
            return 0
        }
        while (token != "]") {
            token = next_token()
            switch (token) {
            case /[\[\{]/:
                sum += parse(token)
                break
            case /[-0-9]+/:
                sum += token
                break
            case "STR":
                break
            case "RED":
                break
            default:
                aoc::compute_error("ERROR 7")
            }
            token = next_token()
            if (token ~ /,\}/) { aoc::compute_error("ERROR 8") }
        }
        return sum+0
    } else { aoc::compute_error("ERROR 9") }
}
{
    nchars = split($0, chars, "")
    currchar = 1
    print parse(next_token())
}
