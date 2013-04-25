%{
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include "process.h"

int yyerror(char*);
int yylex();
 FILE* yyin; 
 int jump_label=0;
 void inst(const char *);
 void instarg(const char *,int);
 void comment(const char *);

 int depl=0;
 int ytype;

 my_map * gmap=NULL;
 
char * name = NULL; /* MODIF DU 25 04 2013  POUR recuperer le nom de la variable*/
%}


%union {
   int entier;
   char * chaine;
   char caractere;
    enum{
   	   	STRING,ENTIER
   }typeExp;

  }

%token<entier>NUM
%token<chaine>CHAINE
%token<chaine>IDENT
%token<chaine>COMP
%token<caractere>ADDSUB
%token<caractere>DIVSTAR
%token<chaine>BOPE
%token<caractere>NEGATION
%token<chaine> TYPE /* MODIF DU 25 04 2013*/
%token EGAL PV VRG LPAR RPAR LACC RACC LSQB RSQB CONST
%token IF  ELSE WHILE RETURN PRINT READ READCH  MAIN  VOID

%left BOPE COMP ADDSUB DIVSTAR NEGATION 
%right ADDSUBUNAIRE

%type <typeExp> Exp
%type <entier> FIXIF FIXELSE ANCRE

%nonassoc NELSE
%nonassoc ELSE

%%
PROGRAMME 			:	/* rien */ | PROGRAMME Prog
						; 
Prog            	:   DeclConst DeclVarPuisFonct DeclMain
						;
DeclConst			:	DeclConst CONST ListConst PV
						|/*rien*/
					;
ListConst			:	 ListConst VRG IDENT EGAL Litteral
						| IDENT EGAL Litteral
						;
Litteral  			: 	NombreSigne
						| CHAINE 		
						;
NombreSigne			: 	NUM  { /* MODIF DU 25 04 2013*/
								instarg("SET",$1);
								inst("PUSH");
						}    		
						| ADDSUB NUM	{/*conflit possible ici*/
											if($1=='-'){
												instarg("SET",$2);
												inst("NEG");                  						
		                   						inst("PUSH");
		                   					}
                   						}
						;
DeclVarPuisFonct 	:	 TYPE ListVar PV DeclVarPuisFonct 
						| DeclFonct
						| /*rien*/
						;
ListVar				: 	ListVar VRG IDENT
						| IDENT
						;
DeclMain  			: 	EnTeteMain Corps
						;
EnTeteMain			:	 MAIN LPAR RPAR
						;
DeclFonct 			:	 DeclFonct DeclUneFonct
						| DeclUneFonct
						;
DeclUneFonct		: 	EnTeteFonct Corps
						;
EnTeteFonct			:	TYPE IDENT LPAR Parametres RPAR
						| VOID IDENT LPAR Parametres RPAR
						;
Parametres			: 	VOID
						| ListTypVar
						;
ListTypVar			: 	ListTypVar VRG TYPE IDENT 
						| TYPE IDENT
						;
Corps				: 	LACC DeclConst DeclVar SuiteInstr RACC
						;
DeclVar 			: 	DeclVar TYPE ListVar PV { /* MODIF DU 25 04 2013*/
							if(strcmp($2,"entier")==0){
								comment("DECARATION D ENTIER\n");
								ytype=ENTIER;
							}
							else {
								comment("DECARATION DE STRING\n");
								ytype=STRING;
							}
						}
						| /*rien*/
						;
SuiteInstr			: 	SuiteInstr Instr
						| /*rien*/
						;
InstrComp			: 	LACC SuiteInstr RACC
						;
Instr 				: 	LValue EGAL Exp PV /* MODIF DU 25 04 2013*/
						{ 
							
							if(ytype == STRING)
							{
									comment("INITIALISATION D'UN STRING\n");
									/*ajouter(gmap,"chaine",name,0,0);*/
									printf("AJOUT DE : chaine %s %s \n",name,$3);
									

							}
							else
							{
									comment("INITIALISATION D'UN INT\n");
									/*ajouter(gmap,"entier",name,$3,0);*/
									printf("AJOUT DE : entier %s %d\n",name,$3);
									

							} 
								
								

						}
						| IF LPAR Exp RPAR  FIXIF Instr %prec NELSE {instarg("LABEL",$5);} 
						| IF LPAR Exp RPAR FIXIF Instr ELSE FIXELSE { instarg("LABEL",$5);} Instr { instarg("LABEL",$8);}
						| WHILE ANCRE LPAR Exp RPAR  FIXIF Instr { instarg("JUMP", $2);instarg("LABEL",$6);}
						| RETURN Exp PV
						| RETURN PV
						| IDENT LPAR Arguments RPAR PV
						| READ LPAR IDENT RPAR PV { instarg("ALLOC",1);
													inst("READ");
													inst("SWAP");
													instarg("SET",depl);
													inst("SWAP");
													inst("SAVE");	}
						| READCH LPAR IDENT RPAR PV { inst("READCH");
													inst("PUSH");	}
						| PRINT LPAR Exp RPAR PV {inst("POP"); 
                           						  inst("WRITE");}
						| PV
						| InstrComp
						;
Arguments			: 	ListExp
						| /*rien*/
						;
LValue				: 	IDENT /* MODIF DU 25 04 2013*/
						{
							name=malloc(sizeof(char*)*strlen($1)+1);
							strcpy(name,$1);printf("name = %s !!!!!!!!!!!!\n",name);
						}
						| IDENT LSQB Exp RSQB 
						;
ListExp				: 	ListExp VRG Exp
						| Exp
						;
Exp 				:	Exp ADDSUB Exp {	
											
											if($1!=$3){

												comment("here not the same typeExp (in ADDSUB )\n");
												inst("HALT");
											}
											inst("POP");
											inst("SWAP"); 
											inst("POP");
											if($2=='+'){
												
												inst("ADD");
												
											}else {
												
												inst("SUB");
											}
											inst("PUSH");
										}
						| Exp DIVSTAR Exp {		
												if($1!=$3){

												comment("here not the same typeExp (in DIVSTAR )\n");
												inst("HALT");
											}
												inst("POP");
												inst("SWAP"); 
												inst("POP");
												
											if($2=='*'){
												inst("MULT");
												
											}else if ($2=='/'){
												
												inst("DIV");
												
											}else{
												
												inst("MOD");
												
											}
											inst("PUSH");
										}
						| Exp COMP Exp  {
											if($1!=$3){

												comment("here not the same typeExp (in COMP)\n");
												
												inst("HALT");
											}
											inst("POP");
											inst("SWAP");
											inst("POP");
											if(strcmp("==",$2)==0){
												
												inst("EQUAL");
											}
											else if(strcmp("!=",$2)==0){
												
												inst("NOTEQ");
											}
											else if(strcmp("<",$2)==0){
												
												inst("LOW");
											}
											else if(strcmp("<=",$2)==0){
												;
												inst("LEQ");
											}
											else if(strcmp(">",$2)==0){
												
												inst("GREAT");
											}
											else if(strcmp(">=",$2)==0){
												
												inst("GEQ");
												
											}
											/*cest dans instruction quon va*/
											/*instarg("JUMPF", $$=jump_label++);	*/
											inst("PUSH");
										}
						| ADDSUB Exp 	{
												inst("POP"); 
												inst("NEG");                  						
		                   						inst("PUSH");
										}
						| Exp BOPE Exp {
											if(strcmp("&&",$2)==0){
												inst("POP");	/* r1= exp1*/
												inst("SWAP");	/* r2 = exp1 */
												inst("POP");	/* r1 = exp2 */
												inst("ADD");	/* r1 = exp1 + exp2 */
												inst("SWAP");	/* r2 = exp1 + exp2 */
												instarg("SET",2); /* r1 = 2 */
												inst("EQUAL");/* si r1 vaut 1 donc exp1=1 et exp2=1 le && est verifier . sinon le && n est pas verifier */
											}
											else {
												inst("POP");	/* r1 = exp1*/
												inst("SWAP");	/* r2 = exp1 */
												inst("POP");    /* r1 = exp2 */
												inst("ADD");	/* r1 = exp1 + exp2 */
												inst("SWAP");	/* r2 = exp1 + exp2 */
												instarg("SET",0); /*r1 = 0 */
												inst("SWAP");	/* r1 = exp1 + exp2     et r2 = 0 */
												inst("GREAT"); 	/* r1 =1  : au moins l une des exp vaut 1 , r1=0 les deux exp valent 0*/
											}
											inst("PUSH");


										}
						| NEGATION Exp {
										inst("POP");	/* r1 = exp*/
										inst("SWAP");	/* r2 = exp */
										instarg("SET",0); /* r1 = 0 */
										inst("EQUAL");/* si r1 vaut 1 donc exp vallait 0 et on a sa negation ,sinon exp etait !=0 donc r1 vaut 0 et on a sa negation */
										inst("PUSH");

									}
						| LPAR Exp RPAR { $$=$$;}
						| LValue { $$=ytype	;}
						| NUM {	
								
								$$=ENTIER;
								ytype = 1 ;	
								instarg("SET",$1);
	                   			inst("PUSH");

                   				}
                   		| CHAINE  {	
                   			ytype = 0 ;
                   			/*printf("%s",$1);*/
									
								$$=STRING;
                   				}            					
                   							
						| IDENT LPAR Arguments RPAR { $$=NUM;}
					    ;
FIXIF:				{
						inst("POP");
						instarg("JUMPF", $$=jump_label++);
					}
					;
FIXELSE :  			{
	  					instarg("JUMP", $$=jump_label++);
					 }
					 ;
ANCRE	:
  					{
  						instarg("LABEL",$$=jump_label++); }
  					;
%%



void endProgram() {
  printf("HALT\n");
}

void inst(const char *s){
  printf("%s\n",s);
}

void instarg(const char *s,int n){
  printf("%s\t%d\n",s,n);
}


void comment(const char *s){
  printf("#%s\n",s);
}

int yyerror(char* s) {
  fprintf(stderr,"%s\n",s);
  return 0;
}

int main(int argc, char** argv) {  
 if(argc==2){
    yyin = fopen(argv[1],"r");
  }
  else if(argc==1){
    yyin = stdin;
  }
  else{
    fprintf(stderr,"usage: %s [src]\n",argv[0]);
    return 1;
  }
  yyparse();
  endProgram();
  return 0;
}






