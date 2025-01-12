%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include <math.h>
    #include <iostream> // For cout
    #include <fstream>  // For file handling
    #include "y.tab.h"
    
    using namespace std;

    extern FILE *yyin;

    void yyerror(const char *msg) {
        fprintf(stderr, "Error: %s\n", msg);
    }

    typedef struct {
        char* name;
        int value;
        int is_const;
        char* expression; // Expression string for evaluation if needed
        int dependent_count; // Count of dependent variables
        char* dependencies[10]; // List of dependencies (names)
    } symbol;

    symbol symbol_table[100];
    int symbol_count = 0;

    symbol* get_symbol(const char* name);
    void insert_symbol(const char* name, int value, int is_const, char* expression);
    void print_symbol_table();

    string finalAssignment = "";

%}

%union {
    int number;
    char* str;
}

%token <number> INTEGER
%token <str> IDENT
%token EQUALSYM PLUSOP SUBOP MULOP DIVOP POWOP SEMICOLON

%type <number> expression

%%

program:
    statement_list
    ;

statement_list:
    statement
    | statement_list statement
    ;

statement:
    IDENT EQUALSYM expression SEMICOLON {
        symbol* left = get_symbol($1);
        if (left == NULL) {
            insert_symbol($1, $3, 0, NULL);  // Variable initialization
            left = get_symbol($1);
        }
        left->value = $3;  // Propagate the value of the right-hand side to the variable
        finalAssignment += "Assigned " + to_string($3) + " to " + string($1) + "\n";
    }
    | IDENT EQUALSYM INTEGER SEMICOLON {
        symbol* left = get_symbol($1);
        if (left == NULL) {
            insert_symbol($1, $3, 1, NULL);  // Constant initialization
            finalAssignment += "Assigned constant " + to_string($3) + " to " + string($1) + "\n";
        }
    }
    ;

expression:
    INTEGER {
        $$ = $1;  // Direct number
    }
    | IDENT {
        symbol* s = get_symbol($1);
        if (s != NULL) {
            if (s->dependent_count > 1) {
                $$ = 0; // Multiple dependencies, use the name itself
                finalAssignment += string($1);  // Just use the identifier
            } else {
                $$ = s->value;  // If only one dependency, use the value
                finalAssignment += to_string(s->value);  // Print the value
            }
        } else {
            $$ = 0;  // If not found, treat as 0 (this could be handled differently)
        }
    }
    | expression PLUSOP expression {
        $$ = $1 + $3;
    }
    | expression SUBOP expression {
        $$ = $1 - $3;
    }
    | expression MULOP expression {
        $$ = $1 * $3;
    }
    | expression DIVOP expression {
        if ($3 != 0) {
            $$ = $1 / $3;
        }
    }
    | expression POWOP expression {
        $$ = (int)pow($1, $3);
    }
    ;

%%

symbol* get_symbol(const char* name) {
    for (int i = 0; i < symbol_count; i++) {
        if (strcmp(symbol_table[i].name, name) == 0) {
            return &symbol_table[i];
        }
    }
    return NULL;
}

void insert_symbol(const char* name, int value, int is_const, char* expression) {
    symbol_table[symbol_count].name = strdup(name);
    symbol_table[symbol_count].value = value;
    symbol_table[symbol_count].is_const = is_const;
    symbol_table[symbol_count].expression = expression;
    symbol_table[symbol_count].dependent_count = 0;
    symbol_count++;
}

void print_symbol_table() {
    for (int i = 0; i < symbol_count; i++) {
        printf("Name: %s, Value: %d, Constant: %d\n", symbol_table[i].name, symbol_table[i].value, symbol_table[i].is_const);
    }
}

int main(int argc, char *argv[]) {
    if (argc > 1) {
        FILE *inputFile = fopen(argv[1], "r");  // Open input file
        if (inputFile == nullptr) {
            cout << "Error opening file: " << argv[1] << endl;
            return 1;  // Return error if file cannot be opened
        }
        yyin = inputFile;  // Set yyin to the input file stream
        yyparse();  // Start parsing
        fclose(inputFile);  // Close input file
    } else {
        cout << "No input file provided!" << endl;
        return 1;  // Return error if no input file is provided
    }

    // Output the final assignments
    cout << finalAssignment;
    return 0;
}