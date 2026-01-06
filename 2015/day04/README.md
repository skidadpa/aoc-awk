2015 Day 04 notes
=================
This solution builds a GAWK extension in order to access the MD5 library from
libcrypto. In addition to libcrrypto, it uses `pkg-config` to find libcrypto
in a portable manner. It also uses `gawkapi.h`. I use homebrew on MacOS, and
after switching to M-series hardware, the latter was no longer automatically
found until I added `export CPATH=$HOMEBREW_PREFIX/include:$CPATH` to the end
of `.zprofile` (i.e., if the gawk include file is installed in a non-standard
directory, it needs to be specified in some way).
