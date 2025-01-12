lex lexx.l
yacc -d yacc.y
g++ lex.yy.c y.tab.c -ll -o myProgram

./myProgram input.txt

