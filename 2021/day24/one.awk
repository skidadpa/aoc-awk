#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
/(inp [w-z])|(((add)|(mul)|(div)|(mod)|(eql)) [w-z] [w-z])/ { program[NR] = $0; next }
/((add)|(mul)|(div)|(mod)|(eql)) [w-z] -?[0-9]+/ { program[NR] = $0; var[$3] = $3+0; next }
{
    aoc::data_error()
}
function run(program, from, to, input) {
    # print "z =", var["z"], "input =", input > DFILE
    for (pc = from+0; pc <= to+0; ++pc) {
        # print pc, ":", program[pc] > DFILE
        split(program[pc], op); switch (op[1]) {
            case "inp": var[op[2]] = input; break
            case "add": var[op[2]] += var[op[3]]; break
            case "mul": var[op[2]] *= var[op[3]]; break
            case "div": if (!var[op[3]]) { aoc::compute_error() }; var[op[2]] = int(var[op[2]] / var[op[3]]); break
            case "mod": if (!var[op[3]]) { aoc::compute_error() }; var[op[2]] = var[op[2]] % var[op[3]]; break
            case "eql": var[op[2]] = var[op[2]] == var[op[3]]; break
            default: aoc::compute_error()
        }
    }
    # print "z =", var["z"] > DFILE
}
# function f2(z, step, digit) { return (z % 26 == digit - B[step]) ? int(z/A[step]) : int(z/A[step]) * 26 + digit + C[step] }
function forward(z, step, digit) { var["z"]=z; run(program, inp[step], inp[step+1]-1, digit); return var["z"] }
function backward(zz, step, digit,    z, i, find) {
    # cases where (z % 26 + B == digit)
    z = zz * A[step]
    if (digit >= B[step] && digit - B[step] < 26) {
        if (z % 26 == digit - B[step]) zs[step][z] = 1
        if (A[step] == 26) zs[step][z + digit - B[step]] = 1
    }
    # cases where (z % 26 + B != digit)
    z = (zz - digit - C[step])
    if (z >= 0 && z % 26 == 0) {
        z = int(z / 26) * A[step]
        if (z % 26 != digit - B[step]) zs[step][z] = 1
        if (A[step] == 26) for (i = 0; i < 26; ++i) if (i != digit - B[step]) zs[step][z+i] = 1
    }
}
END {
    var["w"] = var["x"] = var["y"] = var["z"] = 0
    for (pc in program) if (program[pc] ~ /^inp/) inp[++digits] = pc+0
    if (digits != 14) { aoc::compute_error() }
    inp[15] = NR + 1
    for (d = 1; d <= digits; ++d) {
        split(program[inp[d] + 4], op); A[d] = op[3]
        split(program[inp[d] + 5], op); B[d] = op[3]
        split(program[inp[d] + 15], op); C[d] = op[3]
    }
    zs[15][0] = 1
    for (step = 14; step >= 1; --step) for (z in zs[step+1]) for (d = 1; d <= 9; ++d) backward(z, step, d)

    number = ""
    z = 0
    # print 0, ":", z > DFILE
    for (step = 1; step <= 14; ++step) {
        for (digit = 9; digit >= 1; --digit) {
            zz = forward(z, step, digit)
            if (zz in zs[step+1]) break
        }
        # print step, ":", z, ",", digit, "->", A[step], B[step], C[step], "->", zz > DFILE
        if (digit < 1) { aoc::compute_error() }
        number = number digit
        z = zz
    }
    print number
    split(number, n, "")
    var["z"] = 0
    for (i in n) run(program, inp[i], inp[i+1]-1, n[i])
    if (var["z"]) { aoc::compute_error() }
}
