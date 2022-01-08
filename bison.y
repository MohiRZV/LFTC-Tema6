%{
    #include <string.h>
    #include <stdio.h>
    #include <stdlib.h>
    #include <ctype.h>

    extern int yylex();
    extern int yyparse();
    extern FILE *yyin;
    extern int nrLine;
    void yyerror(const char *s);

	char dataSegment[4096];
	char codeSegment[4096];
	int tmpNo = 0;
	
	void writeASM();
	void newTempName(char* tmpN);
%}
%union {
    int intValue;
    double dblValue;
    char* idValue;
    char token[250];
}

%token <token> IDENTIFIER
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

%type <token> expresie
%type <token> term

%%     

program: start content

start: INT MAIN

content: declarareParam lista_instr final

lista_instr: instr | instr lista_instr

instr: atribuire | instr_intrare | instr_iesire

declarareParam: declarare | declarare declarareParam

declarare: tip IDENTIFIER ';' {
	char varName[256];
	sprintf(varName, "%s dd 0\n", $2);
	strcat(dataSegment, varName);
}

tip: INT

atribuire: IDENTIFIER ASSIGN expresie ';' {
	char code[500];
	sprintf(code, "mov eax, [%s]\n", $3);
	strcat(codeSegment, code);
	sprintf(code, "mov [%s], eax\n\n", $1);
	strcat(codeSegment, code);
}

expresie: term {
	char varName[250];
	newTempName(varName);
	strcpy($$,varName);

	char code[250];
	sprintf(code, isdigit($1[0]) ? "mov eax, %s\n" : "mov eax, [%s]\n", $1);
	strcat(codeSegment, code);
	sprintf(code, "mov [%s], eax\n\n", varName);
	strcat(codeSegment, code);
} | expresie '+' term {
	char varName[250];
	newTempName(varName);
	strcpy($$,varName);

	char code[250];
	sprintf(code, isdigit($1[0]) ? "mov eax, %s\n" : "mov eax, [%s]\n", $1);
	strcat(codeSegment, code);
	sprintf(code, isdigit($3[0]) ? "add eax, dword %s\n" : "add eax, [%s]\n", $3);
	sprintf(code, "mov [%s], eax\n\n", varName);
	strcat(codeSegment, code);
} | expresie '*' term {
	char varName[250];
	newTempName(varName);
	strcpy($$,varName);
	char code[250];
        sprintf(code, isdigit($1[0]) ? "mov eax, %s\n" : "mov eax, [%s]\n", $1);
        strcat(codeSegment, code);
	sprintf(code, isdigit($3[0]) ? "mov ebx, %s\nmul ebx\n" : "mul dword [%s]\n", $3);
        strcat(codeSegment, code);
        sprintf(code, "mov [%s], eax\n\n", varName); 
        strcat(codeSegment, code);
}

term: INT_CONSTANT {
snprintf($$, 250, "%d", $1);
} | IDENTIFIER {
strcpy($$,$1);
}

instr_intrare: CIN GT GT IDENTIFIER ';' {
	char text[350];
	sprintf(text, "push dword %s\npush dword format_i\ncall [scanf]\nadd esp, 4*2\n\n",$4);
	strcat(codeSegment, text);
}

instr_iesire: COUT LT LT IDENTIFIER ';' {
	char text[350];
	sprintf(text, "push dword [%s]\npush dword format_o\ncall [printf]\nadd esp, 4*2\n\n", $4);
	strcat(codeSegment, text);
}

final: RETURN {strcat(codeSegment, "push dword 0\ncall [exit]\n");}

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
    writeASM();
    printf("Nu au fost gasite erori sintactice!\n");
    return 0;
}

void writeASM() {
	FILE* file = fopen("source.asm", "w");
	if (file == NULL) {
		perror("Failed to open file\n");
		exit(1);
	}

	char header[4000];
	strcpy(header, "bits 32\n\n");
	strcat(header, "global start\n\n");
	strcat(header, "extern exit, printf, scanf\n\n");
	strcat(header, "import exit msvcrt.dll\nimport printf msvcrt.dll\nimport scanf msvcrt.dll\n\n");
	fwrite(header, strlen(header), sizeof(char), file);	

	char segmentData[4000];
	strcpy(segmentData, "segment data use32 class=data\nformat_i db '%d', 0\nformat_o db '%d', 10, 13, 0\n");
	strcat(segmentData, dataSegment);
	strcat(segmentData, "\n");
	fwrite(segmentData, strlen(segmentData), sizeof(char), file);

	char segmentCode[4000];
	strcpy(segmentCode, "segment code use32 class=code\nstart:\n");
	strcat(segmentCode, codeSegment);
	
	fwrite(segmentCode, strlen(segmentCode), sizeof(char), file);

	fclose(file);
}

void newTempName(char* tmp) {
	sprintf(tmp, "temp%d dd 1\n", tmpNo);
	strcat(dataSegment, tmp);
	sprintf(tmp, "temp%d", tmpNo);
	tmpNo++;	
}

