.PHONY: test clean update fullclean

test : expected.txt results.txt
	diff expected.txt results.txt && echo results MATCH

PROGRAMS = one.awk two.awk
INPUTS = sample.txt input.txt

results.txt : $(PROGRAMS) $(INPUTS)
	./one.awk sample.txt > $@
	./one.awk input.txt >> $@
	./two.awk sample.txt >> $@
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
