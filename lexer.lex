%{
#include <string.h>
#include "bison.tab.h"

int nrLine = 0;

%}

%option noyywrap
CONST 		[0-9]
ID      	[a-zA-Z]{1,8}
  
%% 
{CONST}+                		{return CONSTANT;}
{CONST}+"."{CONST}*			{return CONSTANT;}
CONST 					{return CONSTANT;}
ID 					{return IDENTIFIER;}
"main(){"				{return MAIN;}
"return 0;}"				{return RETURN;}
int				 	{return INT;}
double					{return DOUBLE;}
cout					{return COUT;}
cin					{return CIN;}
\=					{return ASSIGN;}
\+					{return '+';}
\-					{return '-';}
\*					{return '*';}
\/					{return '/';}
\%					{return '%';}
\==					{return EQ;}
\!=					{return NEQ;}
\{					{return '{';}
\}					{return '}';}
\(					{return '(';}
\)					{return ')';}
\>					{return GT;}
\>= 					{return GE;}
\<					{return LT;}
\<=					{return LE;}
\;					{return ';';}
{ID}					{return IDENTIFIER;}
[\n]			                {nrLine++;}
[ \t]+             			/*skip whitespace*/
.					printf("Something is wrong with\t %s\n", yytext);
%% 
