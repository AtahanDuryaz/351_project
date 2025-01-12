#ifndef _yy_defines_h_
#define _yy_defines_h_

#define INTEGER 257
#define IDENT 258
#define EQUALSYM 259
#define PLUSOP 260
#define SUBOP 261
#define MULOP 262
#define DIVOP 263
#define POWOP 264
#define SEMICOLON 265
#ifdef YYSTYPE
#undef  YYSTYPE_IS_DECLARED
#define YYSTYPE_IS_DECLARED 1
#endif
#ifndef YYSTYPE_IS_DECLARED
#define YYSTYPE_IS_DECLARED 1
typedef union YYSTYPE {
    int number;
    char* str;
} YYSTYPE;
#endif /* !YYSTYPE_IS_DECLARED */
extern YYSTYPE yylval;

#endif /* _yy_defines_h_ */
