.PHONY: test clean update fullclean

test : expected.txt results.txt reference.txt output.txt
	: COMPARING RESULTS
	diff -s expected.txt results.txt && diff -s reference.txt output.txt

reference.txt : | input.txt
	: GENERATING INITIAL OUTPUT REFERENCE $@
	./one.awk input.txt > $@
	./two.awk input.txt >> $@

PROGRAMS = one.awk two.awk
SAMPLES = sample.txt sample2.txt

results.txt : $(PROGRAMS) $(SAMPLES) Makefile
	: GENERATING SAMPLE RESULTS $@
	./one.awk sample.txt > $@
	./one.awk sample2.txt >> $@
	cat $@

output.txt : $(PROGRAMS) input.txt Makefile
	: GENERATING TEST RESULTS $@
	./one.awk input.txt > $@
	./two.awk input.txt >> $@
	cat $@

clean:
	$(RM) results.txt output.txt

fullclean: clean
	$(RM) input.txt reference.txt

update: results.txt output.txt
	: UPDATING REFERENCE FILES
	cp results.txt expected.txt
	cp output.txt reference.txt

input.txt :
	: DOWNLOADING TEST INPUT $@
	aocd $(notdir $(patsubst %/,%,$(dir $(CURDIR)))) $(subst day,,$(notdir $(CURDIR))) > $@
