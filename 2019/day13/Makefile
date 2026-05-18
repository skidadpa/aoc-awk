.PHONY: test clean update fullclean

test : reference.txt output.txt
	: COMPARING RESULTS
	diff -s reference.txt output.txt

reference.txt : | input.txt
	: GENERATING INITIAL OUTPUT REFERENCE $@
	./one.awk input.txt > $@
	./two.awk input.txt >> $@

PROGRAMS = one.awk two.awk

output.txt : $(PROGRAMS) input.txt Makefile
	: GENERATING TEST RESULTS $@
	./one.awk input.txt > $@
	./two.awk input.txt >> $@
	cat $@

clean:
	$(RM) output.txt

fullclean: clean
	$(RM) input.txt reference.txt

update: output.txt
	: UPDATING REFERENCE FILES
	cp output.txt reference.txt

input.txt :
	: DOWNLOADING TEST INPUT $@
	aocd $(notdir $(patsubst %/,%,$(dir $(CURDIR)))) $(subst day,,$(notdir $(CURDIR))) > $@
