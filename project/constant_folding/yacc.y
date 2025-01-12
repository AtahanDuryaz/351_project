%{
    #include <stdio.h>
    #include <iostream>
    #include <string>
    #include <cstdlib>
    #include <cmath>
    using namespace std;
    #include "y.tab.h"  // Include header file to link Lex and Yacc
    extern FILE *yyin;  // Declare the input file pointer
    extern int yylex();  // Declare the lexical analyzer function
    void yyerror(string s);  // Declare error handling function

    string finalAssignment = "";  // To hold the final assignments

    // Helper function for constant folding (calculating expressions)
    string foldConstantOperations(int operand1, int operand2, char op) {
        int result = 0;

        switch (op) {
            case '+': result = operand1 + operand2; break;
            case '-': result = operand1 - operand2; break;
            case '*': result = operand1 * operand2; break;
            case '/': result = operand1 / operand2; break;
            case '^': result = (int)pow(operand1, operand2); break;
            default: return ""; // Invalid operator, shouldn't happen
        }

        return to_string(result);
    }
%}

%union {
    int number;
    char* str;
}

%type <str> expression operand
%token <str> IDENT
%token <number> INTEGER
%token EQUALSYM PLUSOP SUBOP MULOP DIVOP POWOP SEMICOLON

%%

program:
    statement
    | statement program
    ;

statement:
    assignment
    ;

assignment:
    IDENT EQUALSYM expression SEMICOLON
    {
        finalAssignment += string($1) + "=" + string($3) + ";" + "\n";
    }
    ;

expression:
    operand
    {
        $$ = $1;  // Pass operand as string
    }
    |
    operand PLUSOP operand
    {
        if (isdigit($1[0]) && isdigit($3[0])) {
            $$ = strdup(foldConstantOperations(atoi($1), atoi($3), '+').c_str());  // Constant folding for addition
        } else {
            $$ = strdup((string($1) + "+" + string($3)).c_str());
        }
    }
    |
    operand SUBOP operand
    {
        if (isdigit($1[0]) && isdigit($3[0])) {
            $$ = strdup(foldConstantOperations(atoi($1), atoi($3), '-').c_str());  // Constant folding for subtraction
        } else {
            $$ = strdup((string($1) + "-" + string($3)).c_str());
        }
    }
    |
    operand MULOP operand
    {
        if (isdigit($1[0]) && isdigit($3[0])) {
            $$ = strdup(foldConstantOperations(atoi($1), atoi($3), '*').c_str());  // Constant folding for multiplication
        } else {
            $$ = strdup((string($1) + "*" + string($3)).c_str());
        }
    }
    |
    operand DIVOP operand
    {
        if (isdigit($1[0]) && isdigit($3[0])) {
            $$ = strdup(foldConstantOperations(atoi($1), atoi($3), '/').c_str());  // Constant folding for division
        } else {
            $$ = strdup((string($1) + "/" + string($3)).c_str());
        }
    }
    |
    operand POWOP operand
    {
        if (isdigit($1[0]) && isdigit($3[0])) {
            $$ = strdup(foldConstantOperations(atoi($1), atoi($3), '^').c_str());  // Constant folding for exponentiation
        } else {
            $$ = strdup((string($1) + "^" + string($3)).c_str());
        }
    }
    ;

operand:
    IDENT
    {
        $$ = $1;  // Return identifier as is
    }
    |
    INTEGER
    {
        $$ = strdup(to_string($1).c_str());  // Convert integer to string
    }
    ;

%%

void yyerror(string s) {
    cout << "error: " << s << endl;  // Print error message
}

int yywrap() {
    return 1;  // Return 1 to indicate end of input
}

int main(int argc, char *argv[]) {
    if (argc > 1) {
        yyin = fopen(argv[1], "r");  // Open input file
        if (yyin == nullptr) {
            cout << "Error opening file: " << argv[1] << endl;
            return 1;  // Return error if file cannot be opened
        }
        yyparse();  // Start parsing
        fclose(yyin);  // Close input file
    } else {
        cout << "No input file provided!" << endl;
        return 1;  // Return error if no input file is provided
    }

    // Output the final assignments
    cout << finalAssignment;
    return 0;
}
