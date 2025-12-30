/* needed by gawkapi.h */
#include <errno.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>

#include "gawkapi.h"

static awk_ext_id_t ext_id;

#include <openssl/md5.h>

static const gawk_api_t *api;
static awk_ext_id_t ext_id;

int plugin_is_GPL_compatible;

char hex_digit(char val) {
    if (val >= 10) return 'A' + (val - 10);
    else return '0' + val;
}

awk_value_t *do_md5(int nargs, awk_value_t *result, struct awk_ext_func *finfo)
{
    unsigned char md[MD5_DIGEST_LENGTH];
    awk_value_t input;
    char *output;
    int i;

    if (!get_argument(0, AWK_STRING, &input)) {
        warning(ext_id, "md5: bad parameter");
        return make_null_string(result);
    }

    MD5((const unsigned char *)input.str_value.str, input.str_value.len, md);

    ezalloc(output, char *, MD5_DIGEST_LENGTH * 2, "md5");
    for (i = 0; i < MD5_DIGEST_LENGTH; ++i) {
        output[i * 2] = hex_digit(md[i] >> 4);
        output[i * 2 + 1] = hex_digit(md[i] & 0xf);
    }

    return make_malloced_string(output, MD5_DIGEST_LENGTH * 2, result);
}

static awk_ext_func_t func_table[] = {
    { "md5", do_md5, 1, 1, awk_false, NULL }
};

static awk_bool_t
init_md5(void)
{
  return awk_true;
}

static awk_bool_t (*init_func)(void) = init_md5;
static const char *ext_version = "md5 extension: version 1.0";

dl_load_func(func_table, md5, "")
