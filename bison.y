%{
    #include <string.h>
    #include <stdio.h>
    #include <stdlib.h>

    extern int yylex();
    extern int yyparse();
    extern FILE *yyin;
    extern int nrLine;
    void yyerror(const char *s);
%}
%union {
    int intValue;
    double dblValue;
    char* idValue;
}

%token <idValue> IDENTIFIER
%token <intValue> INT_CONSTANT
%token <dblValue> DOUBLE_CONSTANT
%token MAIN
%token INT
%token DOUBLE
%token CIN
%token COUT
%token GT
%token ASSIGN
%token LT
%token GE
%token LE
%token NEQ
%token EQ
%token OR
%token AND
%token NO_PARAMS
%token RETURN 

%%     

program: start content

start: INT MAIN {printf("start:\n");}

content: declarareParam lista_instr final

lista_instr: instr | instr lista_instr

instr: atribuire | instr_intrare | instr_iesire

declarareParam: declarare | declarare declarareParam

declarare: tip IDENTIFIER ';' {printf("declarare:\n");}

tip: INT {printf("integer type ");}| DOUBLE {printf("double type ");}

atribuire: IDENTIFIER ASSIGN expresie ';' {printf("atribuire\n");}

expresie: term | expresie '+' term | expresie '-' term | expresie '*' term | expresie '/' term | expresie '%' term

term: INT_CONSTANT {printf("integer: %d\n", $1);} | DOUBLE_CONSTANT {printf("double: %f\n",$1);} | IDENTIFIER {printf("identifier: %s\n",$1);}

instr_intrare: CIN GT GT IDENTIFIER ';' {
	     printf("intrare\n");
		printf("chestie\n");
}

instr_iesire: COUT LT LT IDENTIFIER ';' {printf("iesire\n");}

final: RETURN {printf("end\n");}

%%
void yyerror(const char *s) {
    printf("%s was detected! Please check your code!\n", s);
    exit(1);
}

int main(int argc, char *argv[]) {
    ++argv, --argc; /* skip over program name */ 
    
    // sets the input for flex file
    if (argc > 0) 
        yyin = fopen(argv[0], "r"); 
    else 
        yyin = stdin; 
    
    //read each line from the input file and process it
    while (!feof(yyin)) {
        yyparse();
    }
    printf("Nu au fost gasite erori sintactice!\n");
    return 0;
}

