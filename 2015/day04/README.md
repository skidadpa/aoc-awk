2015 Day 04 notes
=================
This solution builds a GAWK extension in order to access the MD5 library from
libcrypto. In addition to libcrrypto, it uses `pkg-config` to find libcrypto
in a portable manner. It also uses `gawkapi.h`. I use homebrew on MacOS, and
after switching to M-series hardware, the latter was no longer automatically
found until I added `export CPATH=$HOMEBREW_PREFIX/include:$CPATH` to the end
of `.zprofile` (i.e., if the gawk include file is installed in a non-standard
directory, it needs to be specified in some way).

For some reason, the library will sometimes randomly cause an internal error
and the program will fail. This seems to happen more frequently when running
`make` on a clean install. The error is transient, so removing any corrupted
output files and running again is usually all that is needed.

Note that future verions of this module (e.g., 2016 day 17) do not crash although return const strings vs malloc strings. Not sure whether that is feasible here, again more investigation is needed...
