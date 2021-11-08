BIN = a.out

all: compile

compile:
	cd src &&\
	flex lex.l &&\
	yacc translate.y -d -v &&\
	gcc -o $(BIN) symbol.h symbol.c -lm montador_lexer.h montador_lexer.c -lm\
		hash-table.h hash-table.c y.tab.c lex.yy.c y.tab.h -ll ;\
	cd ..

llvm:
	llvm-as cod.ll -o cod.bc &&\
	llc cod.bc -o cod.s &&\
	clang-10 cod.s -o cod.native &&\
	echo "\nTo run the code, please execute: make run_native"

run:
	./src/$(BIN)

run_native:
	./cod.native
