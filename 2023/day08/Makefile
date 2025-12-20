.PHONY: test clean update fullclean

test : expected.txt results.txt
	diff -s expected.txt results.txt

PROGRAMS = one.awk two.awk
INPUTS = sample.txt sample2.txt sample3.txt input.txt

results.txt : $(PROGRAMS) $(INPUTS)
	./one.awk sample.txt > $@
	./one.awk sample2.txt >> $@
	./one.awk input.txt >> $@
	./two.awk sample.txt >> $@
	./two.awk sample2.txt >> $@
	./two.awk sample3.txt >> $@
	./two.awk input.txt >> $@
	cat $@

clean:
	$(RM) results.txt

fullclean: clean
	$(RM) input.txt

update: results.txt
	cp $< expected.txt

input.txt :
	aocd $(notdir $(patsubst %/,%,$(dir $(CURDIR)))) $(subst day,,$(notdir $(CURDIR))) > $@
