/* needed by gawkapi.h */
#include <errno.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>

#include "gawkapi.h"

int plugin_is_GPL_compatible;
static const gawk_api_t *api;
static awk_ext_id_t ext_id;
static const char *ext_version = "day23 2017 extension: version 1.0";

static long run_program(long a, long b)
{
    long c=0, d=0, e=0, f=0, g=0, h=0;
    /*
     * set b SOME_VAL
     * set c b
     * jnz a 2
     * jnz 1 5
     */
    c = b;

    if (a)
    {
        /*
         * mul b 100
         * sub b -100000
         * set c b
         * sub c -17000
         */
        b = b * 100 + 100000;
        c = b + 17000;
    }

    do
    {
        /*
         * set f 1
         * set d 2
         */  
        f = 1;
        d = 2;
        do
        {
            /*
             * set e 2
             * set g d
             * mul g e
             * sub g b
             * jnz g 2
             * set f 0
             * sub e -1
             * set g e
             * sub g b
             * jnz g -8
             *
             * i.e.,
             *
             * e = 2;
             * do {
             *     if (d * e == b) {
             *         f = 0;
             *     }
             *     ++e;
             * } while (e != b);
             *
             * becomes:
             */
            if (b % d == 0)
            {
                f = 0;
            }
            /*
             * sub d -1
             * set g d
             * sub g b
             * jnz g -13
             */
            ++d;
        }
        while (b != d);

        /*
         * jnz f 2
         */
        if (!f) {
            ++h;
        }

        /*
         * set g b
         * sub g c
         * jnz g 2
         * jnz 1 3
         */
        if (b == c)
        {
            return h;
        }

        /*
         * sub b -17
         * jnz 1 -23
         */
        b += 17;
    }
    while (1);
}

awk_value_t *day23_2017_part2(int nargs, awk_value_t *result, struct awk_ext_func *finfo)
{
    awk_value_t aval;
    awk_value_t bval;
    long a;
    long b;
    long h;

    if (!get_argument(0, AWK_NUMBER, &aval)) {
        warning(ext_id, "day23 2017 part 2: bad a parameter");
        return make_null_string(result);
    }
    if (!get_argument(1, AWK_NUMBER, &bval)) {
        warning(ext_id, "day23 2017 part 2: bad b parameter");
        return make_null_string(result);
    }

    a = (long)aval.num_value;
    b = (long)bval.num_value;

    h = run_program(a, b);

    return make_number((double)h, result);
}

static awk_ext_func_t func_table[] = {
    { "day23_2017_part2", day23_2017_part2, 1, 1, awk_false, NULL }
};

static awk_bool_t
init_day23(void)
{
  return awk_true;
}

static awk_bool_t (*init_func)(void) = init_day23;

dl_load_func(func_table, day23_2017_part2, "")
