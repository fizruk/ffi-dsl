main: Main.hs test.o DSLFFI.o
	ghc --make -threaded -main-is main -o $@ $^

test.o: test.c test.h DSLFFI_stub.h
	gcc -c -o $@ $<

%_stub.h: %.hs
	ghc --make -threaded $*.hs

.PHONY: clean

clean:
	rm -f main *_stub.h *.o *.hi **/*_stub.h **/*.o **/*.hi
