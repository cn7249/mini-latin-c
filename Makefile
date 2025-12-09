CC = gcc
FLEX = flex
BISON = bison
CFLAGS = -Wall -g
SRC = src

.PHONY: all clean

all: latinc

# generate parser
$(SRC)/parser.tab.c $(SRC)/parser.tab.h: $(SRC)/parser.y
	$(BISON) -d -o $(SRC)/parser.tab.c $(SRC)/parser.y

# generate lexer
$(SRC)/lex.yy.c: $(SRC)/lexer.l $(SRC)/parser.tab.h
	cd $(SRC) && flex ../lexer.l
	@mv $(SRC)/lex.yy.c $(SRC)/lex.yy.c || true

OBJS = $(SRC)/parser.tab.o $(SRC)/lex.yy.o $(SRC)/ast.o $(SRC)/interp.o $(SRC)/main.o

$(SRC)/parser.tab.o: $(SRC)/parser.tab.c
	$(CC) $(CFLAGS) -c -o $@ $<

$(SRC)/lex.yy.o: $(SRC)/lex.yy.c
	$(CC) $(CFLAGS) -c -o $@ $<

$(SRC)/ast.o: $(SRC)/ast.c $(SRC)/ast.h
	$(CC) $(CFLAGS) -c -o $@ $(SRC)/ast.c

$(SRC)/interp.o: $(SRC)/interp.c $(SRC)/ast.h
	$(CC) $(CFLAGS) -c -o $@ $(SRC)/interp.c

$(SRC)/main.o: $(SRC)/main.c $(SRC)/ast.h
	$(CC) $(CFLAGS) -c -o $@ $(SRC)/main.c

latinc: $(OBJS)
	$(CC) -o latin-c $(OBJS) $(CFLAGS)

clean:
	rm -f $(SRC)/*.o $(SRC)/parser.tab.c $(SRC)/parser.tab.h $(SRC)/lex.yy.c latin-c
