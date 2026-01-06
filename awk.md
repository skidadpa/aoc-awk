Notes on AWK
============
This project actually uses Gnu AWK (gawk). Having come from Bell Labs myself,
it is tempting to use the One True AWK, which is actually maintained (though
sporadically) and can be found at https://github.com/onetrueawk/awk.

However, early on in this effort I switched over to Gnu AWK. Initially this
was simply to get updates via Homebrew, although once I needed to add custom
extensions, there was no going back (even though the One True AWK is now well
supported by Homebrew).

I had run into some other issues with the old AWK. There are some operations
that were not so cleanly defined, especially dealing with differences between
strings and numbers. Gnu AWK has been improving the standardization of this
type of thing (which can cause some pain when porting old programs forward).

One very common error that I make along these lines is comparing array index
values and leaving out numeric coercions:

	max_index = -1 # index is a numeric value
	for (i in ARRAY) {
		if ( max_index < i ) { max_index = i }  # WRONG
		if ( max_index < 0 + i ) { max_index = 0 + i }  # CORRECT
		if ( 0 + max_index < 0 + i ) { max_index = i }  # ALSO WORKS
	}

This is a bit of a contrived example, I'd probably track of `max_index` from
the outset instead.

You could also do something like this:

	max_index = -1
	PROCINFO["sorted_in"] = "@ind_num_desc"
	for (i in ARRAY) {
		max_index = 0 + i
		break
	}

:-)
