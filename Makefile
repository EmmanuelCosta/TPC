CC=gcc
CFLAGS=-Wall -ansi
LDFLAGS=-Wall -lfl process.c -I ./
EXEC=projet

all: $(EXEC) clean

$(EXEC): $(EXEC).o  lex.yy.o
	$(CC) -o $@ $^ $(LDFLAGS) -lm

$(EXEC).c: $(EXEC).y
	bison -d -o $(EXEC).c $(EXEC).y

$(EXEC).h: $(EXEC).c

lex.yy.c: $(EXEC).lex $(EXEC).h
	  flex $(EXEC).lex

%.o: %.c
	$(CC) -o $@ -c  $< $(CFLAGS)

clean:
	rm -f lex.yy.* $(EXEC).[och]
