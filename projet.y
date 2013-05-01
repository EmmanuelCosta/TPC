%{
#include "process.h"

int yyerror(char*);
int yylex();
 FILE* yyin; 
 int jump_label=0;

 void inst(const char *);
 void instarg(const char *,int);
 void comment(const char *);
 void sauvegardeEntier(int valeur);
void sauvegardeChaine(char * chaine);
void chargerEntier(int adresse);
void chargerString(int adresse);

 int depl=0;
 int p=0;


 storeIdentValue ytype;
 storeIdentValueAuxi ytype_auxi;
  storeIdentValue ytypetemp;



 my_map * gmap=NULL;
 int vb=0;
 %}


%union {

   int entier;
   char * chaine;
   char caractere; 	
   TYPEEXP typeExp;
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
ListVar				: 	ListVar VRG IDENT { 

											if(ytype_auxi.typey == ENTIER)
												gmap=ajouter(gmap,"entier",$3,NULL,0,0,'e',depl);
											else
												gmap=ajouter(gmap,"chaine",$3,"NULL",0,0,'s',depl);
												p++;
												depl++;

											}
						| IDENT {	
											if(ytype_auxi.typey==ENTIER)
												gmap=ajouter(gmap,"entier",$1,NULL,0,0,'e',depl);
											else
												gmap=ajouter(gmap,"chaine",$1,"NULL",0,0,'s',depl);
												p++;
												depl++;
											}
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
DeclVar 			: 	DeclVar TYPE { 
										if(strcmp($2,"entier")==0){
											comment("DECARATION D ENTIER\n");
											ytype_auxi.typey = ENTIER;
										}
										else {
										comment("DECARATION DE STRING\n");

										ytype_auxi.typey = STRING;

									}
						}  ListVar PV 
						| /*rien*/
						;
SuiteInstr			: 	SuiteInstr Instr
						| /*rien*/
						;
InstrComp			: 	LACC SuiteInstr RACC
						;
Instr 				: 	LValue EGAL Exp PV { 

											if(ytype_auxi.typey == STRING){
												comment("INITIALISATION D'UN STRING\n");
												gmap=ajouter(gmap,"chaine",ytype_auxi.name,ytype_auxi.value,0,0,'s',depl);
												p++;
												sauvegardeChaine(ytype_auxi.value);

											}
											else{

												comment("INITIALISATION D'UN INT\n");
												gmap=ajouter(gmap,"entier",ytype_auxi.name,"NULL",atoi(ytype_auxi.value),0,'e',depl);
												p++;
												sauvegardeEntier(atoi(ytype_auxi.value));
											} 
								
								

						}
						| IF LPAR Exp RPAR FIXIF Instr %prec NELSE {instarg("LABEL",$5);} 
						| IF LPAR Exp RPAR FIXIF Instr ELSE FIXELSE { instarg("LABEL",$5);} Instr { instarg("LABEL",$8);}
						| WHILE ANCRE LPAR Exp RPAR  FIXIF Instr { instarg("JUMP", $2);instarg("LABEL",$6);}
						| RETURN Exp PV
						| RETURN PV
						| IDENT LPAR Arguments RPAR PV
						| READ LPAR IDENT RPAR PV { 
													instarg("ALLOC",1);
													inst("READ");
													inst("SWAP");
													instarg("SET",depl);
													inst("SWAP");
													inst("SAVE");	
												}
						| READCH LPAR IDENT RPAR PV { 
													inst("READCH");
													inst("PUSH");
													}
						| PRINT LPAR Exp RPAR PV {
												  inst("POP"); 
                           						  inst("WRITE"); affiche(gmap);
                           						}
						| PV
						| InstrComp
						;
Arguments			: 	ListExp
						| /*rien*/
						;
LValue				: 	IDENT /* MODIF DU 25 04 2013*/
						{
							strcpy(ytype_auxi.name,$1);
							AjoutStoreIdentValue(&ytype,ytype_auxi.name);ytype_auxi.typey=3;
							ytype->typey=3;
							strcpy(ytype->value,ytype_auxi.value);

						}
						| IDENT LSQB Exp RSQB {comment("DECARATION D' UN TABLEAU\n");}
						;
ListExp				: 	ListExp VRG Exp
						| Exp
						;
Exp 				:	Exp ADDSUB Exp {	

											ytypetemp=ExtraitTete(&ytype);
											strcpy($1.ident,ytypetemp->name);
											strcpy($1.valeur,ytypetemp->value);
											$1.my_type=ytypetemp->typey;
											ytypetemp=ExtraitTete(&ytype);
											strcpy($3.ident,ytypetemp->name);
											strcpy($3.valeur,ytypetemp->value);
											$3.my_type=ytypetemp->typey;


											if($1.my_type==STRING || $3.my_type==STRING){
												perror("pas de comparaison de string");
												exit(0);

											}
											if(getType(gmap,$1.ident)==STRING || getType(gmap,$3.ident)==STRING){
												perror("pas de comparaison de string");
												exit(0);

											}
											if((getType(gmap,$1.ident)<0 && $1.my_type==3 ) || (getType(gmap,$3.ident)<0 && $3.my_type==3) ){
												perror("ident inexistant");
												exit(0);
											}
												if($1.my_type==3){
												sprintf($1.valeur,"%d",getEntier(gmap,$1.ident));
											}
											else strcpy($1.valeur,$1.ident);


											if($3.my_type==3){
												sprintf($3.valeur,"%d",getEntier(gmap,$3.ident));
											}
											else strcpy($3.valeur,$3.ident);



											inst("POP");
											inst("SWAP"); 
											inst("POP");
											if($2=='+'){
												
												libere_storeIdentValue(&ytype);
												AjoutStoreIdentValue(&ytype,"resultat");
												sprintf(ytype->name,"%d",atoi($3.valeur)+atoi($1.valeur));
												ytype->typey=ENTIER;
												sprintf(ytype->value,"%d",atoi($3.valeur)+atoi($1.valeur));

												inst("ADD");
												
											}else {
												libere_storeIdentValue(&ytype);
												AjoutStoreIdentValue(&ytype,"resultat");
												sprintf(ytype->name,"%d",atoi($3.valeur)-atoi($1.valeur));
												ytype->typey=ENTIER;
												sprintf(ytype->value,"%d",atoi($3.valeur)-atoi($1.valeur));
													
												inst("SUB");
											}
											inst("PUSH");
										}
						| Exp DIVSTAR Exp {		

											ytypetemp=ExtraitTete(&ytype);
											strcpy($1.ident,ytypetemp->name);
											strcpy($1.valeur,ytypetemp->value);
											$1.my_type=ytypetemp->typey;
											ytypetemp=ExtraitTete(&ytype);
											strcpy($3.ident,ytypetemp->name);
											strcpy($3.valeur,ytypetemp->value);
											$3.my_type=ytypetemp->typey;


											if($1.my_type==STRING || $3.my_type==STRING){
												perror("pas de comparaison de string");
												exit(0);

											}
											if(getType(gmap,$1.ident)==STRING || getType(gmap,$3.ident)==STRING){
												perror("pas de comparaison de string");
												exit(0);

											}
											if((getType(gmap,$1.ident)<0 && $1.my_type==3 ) || (getType(gmap,$3.ident)<0 && $3.my_type==3) ){
												perror("ident inexistant");
												exit(0);
											}
												if($1.my_type==3){
												sprintf($1.valeur,"%d",getEntier(gmap,$1.ident));
											}
											else strcpy($1.valeur,$1.ident);
											

											if($3.my_type==3){
												sprintf($3.valeur,"%d",getEntier(gmap,$3.ident));
											}
											else strcpy($3.valeur,$3.ident);

												
											inst("POP");
											inst("SWAP"); 
											inst("POP");
												
											if($2=='*'){

												libere_storeIdentValue(&ytype);
												AjoutStoreIdentValue(&ytype,"resultat");
												sprintf(ytype->name,"%d",atoi($3.valeur)*atoi($1.valeur));
												ytype->typey=ENTIER;
												sprintf(ytype->value,"%d",atoi($3.valeur)*atoi($1.valeur));

												inst("MULT");
												
											}else if ($2=='/'){
												libere_storeIdentValue(&ytype);
												AjoutStoreIdentValue(&ytype,"resultat");
												sprintf(ytype->name,"%d",atoi($3.valeur)/atoi($1.valeur));
												ytype->typey=ENTIER;
												sprintf(ytype->value,"%d",atoi($3.valeur)/atoi($1.valeur));
													
												inst("DIV");
												
											}else{
												
												libere_storeIdentValue(&ytype);
												AjoutStoreIdentValue(&ytype,"resultat");
												sprintf(ytype->name,"%d",atoi($3.valeur)%atoi($1.valeur));
												ytype->typey=ENTIER;
												sprintf(ytype->value,"%d",atoi($3.valeur)%atoi($1.valeur));

												inst("MOD");
												
											}
											inst("PUSH");
										}
						| Exp COMP Exp  {

											ytypetemp=ExtraitTete(&ytype);
											strcpy($1.ident,ytypetemp->name);
											strcpy($1.valeur,ytypetemp->value);
											$1.my_type=ytypetemp->typey;
											ytypetemp=ExtraitTete(&ytype);
											strcpy($3.ident,ytypetemp->name);
											strcpy($3.valeur,ytypetemp->value);
											$3.my_type=ytypetemp->typey;


											if($1.my_type==STRING || $3.my_type==STRING){
												perror("pas de comparaison de string");
												exit(0);

											}
											if(getType(gmap,$1.ident)==STRING || getType(gmap,$3.ident)==STRING){
												perror("pas de comparaison de string");
												exit(0);

											}
											if((getType(gmap,$1.ident)<0 && $1.my_type==3 ) || (getType(gmap,$3.ident)<0 && $3.my_type==3) ){
												perror("ident inexistant");
												exit(0);
											}
												if($1.my_type==3){
												sprintf($1.valeur,"%d",getEntier(gmap,$1.ident));
											}
											else strcpy($1.valeur,$1.ident);
											

											if($3.my_type==3){
												sprintf($3.valeur,"%d",getEntier(gmap,$3.ident));
											}
											else strcpy($3.valeur,$3.ident);

											inst("POP");
											inst("SWAP");
											inst("POP");

											if(strcmp("==",$2)==0){
												if(atoi($3.valeur)==atoi($1.valeur)){
													libere_storeIdentValue(&ytype);
													AjoutStoreIdentValue(&ytype,$3.ident);
													ytype->typey=$3.my_type;
												}
												inst("EQUAL");
											}
											else if(strcmp("!=",$2)==0){
												if(atoi($3.valeur)!=atoi($1.valeur)){
													libere_storeIdentValue(&ytype);
													AjoutStoreIdentValue(&ytype,$3.ident);
													ytype->typey=$3.my_type;
												}
												
												inst("NOTEQ");
											}
											else if(strcmp("<",$2)==0){
												if(min(atoi($3.valeur),atoi($1.valeur))==atoi($3.valeur)){
													/*libere_storeIdentValue(&ytype);*/
													AjoutStoreIdentValue(&ytype,$3.ident);
													ytype->typey=$3.my_type;
												}

												inst("LOW");
											}
											else if(strcmp("<=",$2)==0){
												if(min(atoi($3.valeur),atoi($1.valeur))==atoi($3.valeur)){
													libere_storeIdentValue(&ytype);
													AjoutStoreIdentValue(&ytype,$3.ident);
													ytype->typey=$3.my_type;
												}

												inst("LEQ");
											}
											else if(strcmp(">",$2)==0){
												if(max(atoi($3.valeur),atoi($1.valeur))==atoi($3.valeur)){
													libere_storeIdentValue(&ytype);
													AjoutStoreIdentValue(&ytype,$3.ident);
													ytype->typey=$3.my_type;
												}

												inst("GREAT");
											}
											else if(strcmp(">=",$2)==0){
												if(max(atoi($3.valeur),atoi($1.valeur))==atoi($3.valeur)){
													libere_storeIdentValue(&ytype);
													AjoutStoreIdentValue(&ytype,$3.ident);
													ytype->typey=$3.my_type;
												}

												inst("GEQ");
												
											}
											/*cest dans instruction quon va*/
											/*instarg("JUMPF", $$=jump_label++);	*/
											inst("PUSH");
										}
						| ADDSUB Exp 	{
											ytypetemp=ExtraitTete(&ytype);
											strcpy($2.ident,ytypetemp->name);
											strcpy($2.valeur,ytypetemp->value);											
											$2.my_type=ytypetemp->typey;


											if( $2.my_type==STRING){
												perror("pas de comparaison de string");
												exit(0);

											}


											if(getType(gmap,$2.ident)==STRING){
												perror("pas de comparaison de string");
												exit(0);

											}
											if((getType(gmap,$2.ident)<0 && $2.my_type==3 )){
												perror("ident inexistant");
												exit(0);
											}
												if($2.my_type==3){
												sprintf($2.valeur,"%d",getEntier(gmap,$2.ident));
											}
																


											libere_storeIdentValue(&ytype);
											AjoutStoreIdentValue(&ytype,"resultat");
											sprintf(ytype->name,"%d",-(atoi($2.valeur)));
											ytype->typey=ENTIER;
											sprintf(ytype->value,"%d",-(atoi($2.valeur)));

										

											inst("POP"); 
											inst("NEG");                  						
	                   						inst("PUSH");
										}
						| Exp BOPE Exp {

											ytypetemp=ExtraitTete(&ytype);
											strcpy($1.ident,ytypetemp->name);
											strcpy($1.valeur,ytypetemp->value);
											$1.my_type=ytypetemp->typey;
											ytypetemp=ExtraitTete(&ytype);
											strcpy($3.ident,ytypetemp->name);
											strcpy($3.valeur,ytypetemp->value);
											$3.my_type=ytypetemp->typey;


											if($1.my_type==STRING || $3.my_type==STRING){
												perror("pas de comparaison de string");
												exit(0);

											}


											if(getType(gmap,$1.ident)==STRING || getType(gmap,$3.ident)==STRING){
												perror("pas de comparaison de string");
												exit(0);

											}
											if((getType(gmap,$1.ident)<0 && $1.my_type==3 ) || (getType(gmap,$3.ident)<0 && $3.my_type==3) ){
												perror("ident inexistant");
												exit(0);
											}
												if($1.my_type==3){
												sprintf($1.valeur,"%d",getEntier(gmap,$1.ident));
											}
											else strcpy($1.valeur,$1.ident);
											

											if($3.my_type==3){
												sprintf($3.valeur,"%d",getEntier(gmap,$3.ident));
											}
											else strcpy($3.valeur,$3.ident);

							
			
											inst("POP");	/* r1 = exp1*/
											inst("SWAP");	/* r2 = exp1 */
											inst("POP");    /* r1 = exp2 */
											inst("ADD");	/* r1 = exp1 + exp2 */
											inst("SWAP");	/* r2 = exp1 + exp2 */

											if(strcmp("&&",$2)==0){
												
												libere_storeIdentValue(&ytype);
												AjoutStoreIdentValue(&ytype,"resultat");
												sprintf(ytype->name,"%d",atoi($3.valeur)&&atoi($1.valeur));
												ytype->typey=ENTIER;
												sprintf(ytype->value,"%d",atoi($3.valeur)&&atoi($1.valeur));
	
												instarg("SET",2); /* r1 = 2 */
												inst("EQUAL");/* si r1 vaut 1 donc exp1=1 et exp2=1 le && est verifier . sinon le && n est pas verifier */
											}
											else {

												libere_storeIdentValue(&ytype);
												AjoutStoreIdentValue(&ytype,"resultat");
												sprintf(ytype->name,"%d",atoi($3.valeur)||atoi($1.valeur));
												ytype->typey=ENTIER;
												sprintf(ytype->value,"%d",atoi($3.valeur)||atoi($1.valeur));
	
												instarg("SET",0); /*r1 = 0 */
												inst("SWAP");	/* r1 = exp1 + exp2     et r2 = 0 */
												inst("GREAT"); 	/* r1 =1  : au moins l une des exp vaut 1 , r1=0 les deux exp valent 0*/
											}
											inst("PUSH");


										}
						| NEGATION Exp {

										ytypetemp=ExtraitTete(&ytype);
										strcpy($2.ident,ytypetemp->name);
										strcpy($2.valeur,ytypetemp->value);										
										$2.my_type=ytypetemp->typey;

										if( $2.my_type==STRING){
											perror("pas de comparaison de string");
											exit(0);

										}

										if(getType(gmap,$2.ident)==STRING){
											perror("pas de comparaison de string");
											exit(0);

										}
										if((getType(gmap,$2.ident)<0 && $2.my_type==3 )){
											perror("ident inexistant");
											exit(0);
										}
										if($2.my_type==3){
											sprintf($2.valeur,"%d",getEntier(gmap,$2.ident));
										}
							


										inst("POP");	/* r1 = exp*/
										inst("SWAP");	/* r2 = exp */										
										instarg("SET",0); /* r1 = 0 */
										inst("EQUAL");/* si r1 vaut 1 donc exp vallait 0 et on a sa negation ,sinon exp etait !=0 donc r1 vaut 0 et on a sa negation */



										libere_storeIdentValue(&ytype);
										AjoutStoreIdentValue(&ytype,"resultat");
										sprintf(ytype->name,"%d",!(atoi($2.valeur)));
										ytype->typey=ENTIER;
										sprintf(ytype->value,"%d",!(atoi($2.valeur)));
										
										inst("PUSH");

									}
						| LPAR Exp RPAR { $$=$$;}
						| LValue { $$.my_type=ytype_auxi.typey	;}
						| NUM {	
				
								ytype_auxi.typey = ENTIER ;
								strcpy($$.valeur,ytype_auxi.name);								
								sprintf(ytype_auxi.value,"%d",$1);								
								AjoutStoreIdentValue(&ytype,ytype_auxi.value);
								ytype->typey=ENTIER;


								instarg("SET",$1);
	                   			inst("PUSH");

                   				}

                   		| CHAINE  {	
                   										
								ytype_auxi.typey = STRING ;
								strcpy($$.valeur,ytype_auxi.name);		
									strcpy(ytype_auxi.value,$1);
								AjoutStoreIdentValue(&ytype,ytype_auxi.value);
								ytype->typey=STRING;

													
							
                   				}            					
                   							
						| IDENT LPAR Arguments RPAR { $$.my_type=NUM;}

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



void sauvegardeEntier(int valeur){
  instarg("SET",depl);
  inst("SWAP");
  instarg("SET",valeur);
  inst("SAVE");

  depl++;
}

void sauvegardeChaine(char * chaine){
  int length = strlen(chaine);
  int i = 0;

    instarg("SET",depl);  /* je stocke le nombre de référence de la chaine */
    inst("SWAP");
    instarg("SET",length);
    inst("SAVER");
    depl++;
  for(i=0;i<=length;i++){ /*  je stocke tout un par un */
    instarg("SET",depl);
    inst("SWAP");
    instarg("SET",chaine[i]);
    inst("SAVER");
    depl++;
  } 
    instarg("SET",depl);  /* je stocke l entier 0 pour dire fin de la chaine */
    inst("SWAP");
    instarg("SET",0);
    inst("SAVER");
    depl++;


}

void chargerEntier(int adresse){
  instarg("SET",adresse);
  inst("LOAD"); /* Palce dans reg1 la valeur situé à l adresse reg1 */
  inst("PUSH"); /* on le remet en tete de pile (pas forcément necessaire) */
}

/*void chargerString(int adresse){
  
  

}*/


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






