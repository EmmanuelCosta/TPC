%{
#include "process.h"
#include "projet.h"

#include <math.h>


  int fileno (FILE *stream); /*non ansi*/

%}
%option noyywrap
/* evite d'utiliser -lfl */
%%
[ \n\t]+ ;
"entier"|"chaine" {yylval.chaine=malloc(sizeof(char)*(strlen(yytext)+1));
			strcpy(yylval.chaine,yytext); return TYPE;}
"print"	{return PRINT;}
"read" {return READ;}
"readch" {return READCH;}
"main" {return MAIN;}
"const" {return CONST;}
"void" {return VOID;}
"=" {return EGAL;}
"+"|"-"	{sscanf(yytext,"%c",&yylval.caractere); return ADDSUB;}
"*"|"/"|"%" {sscanf(yytext,"%c",&yylval.caractere); return DIVSTAR;}
"!"	{sscanf(yytext,"%c",&yylval.caractere); return NEGATION;}
"=="|"!="|"<"|">"|"<="|">=" {yylval.chaine=malloc(sizeof(char)*(strlen(yytext)+1));
			strcpy(yylval.chaine,yytext); return COMP;}
"||"|"&&" {yylval.chaine=malloc(sizeof(char)*(strlen(yytext)+1));
			strcpy(yylval.chaine,yytext); return BOPE;}
";"	{return PV;}
","	{return VRG;}
"("	{return LPAR;}
")"	{return RPAR;}
"{"	{return LACC;}
"}"	{return RACC;}
"["	{return LSQB;}
"]"	{return RSQB;}
"if" {return IF;}
"else" {return ELSE;}
"while" {return WHILE;}
"return"	{return RETURN;}
[A-Za-z]+[0-9_]* {yylval.chaine=malloc(sizeof(char)*(strlen(yytext)+1));
			strcpy(yylval.chaine,yytext); return IDENT;}
[0-9]+ {sscanf(yytext,"%d",&yylval.entier); return NUM;}
["][A-Za-z]*["]|['][A-Za-z]['] {yylval.chaine=malloc(sizeof(char)*(strlen(yytext)+1));
			strcpy(yylval.chaine,yytext); return CHAINE;}
.|\n return yytext[0];
%%