AWK extensions
==============
Several of the challenges have involved computing (often a very large number
of) MD5 checksums. Since this is a cryptographic calculation intended to be
somewhat computationally intensive, it is not feasible to use an interpreted
AWK-based solution in general. Since MD5() is a readily-available library
function, adding it as an AWK extension seemed like fair game to me.

Note that the current md5() extension returns a `malloced_string` of size
`MD5_DIGEST_LENGTH * 2 + 1`. Looking back into old solutions, some of them
were returning `const_string` values pointing at their own static data. One
was returning a `malloced_string` but of size `MD5_DIGEST_LENGTH * 2` (and
intermittently crashing). The reason for both was that with my old machine
and the current version of AWK at the time, I would run out of memory when
doing it "correctly". This is no longer an issue for me, but if encounter
out of memory conditions with the current implementations, this may be why.

Building extensions
-------------------
The solutions use `pkg-config` to find libraries (`libcrypto` for `MD5()`),
so this needs to be installed in addition to any required libraries. Also,
AWK extensions need to include `gawkapi.h`.

I use Homebrew on MacOS and found that after switching to M-series hardware,
`gawkapi.h` was no longer being found. To resolve this, I needed to add the
following to the end of `.zprofile`:

	export CPATH=$HOMEBREW_PREFIX/include:$CPATH

For Intel-based Macs, `HOMEBREW_PREFIX` defaults to `/usr/local`, for newer
models, it defaults to `/opt/homebrew`.
