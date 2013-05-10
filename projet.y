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
void sauvegardeEntier2(int valeur,int adresse);
void sauvegardeChaine(char * chaine);
void chargerEntier(int adresse);
void chargerEntierTAS(int adresse);
void chargerString(int adresse);
void storeGlobal();


 int depl=0;
 int p=0;
 int tas=0;


storeIdentValue ytype;
storeIdentValueAuxi ytype_auxi;
storeIdentValue ytypetemp;

listvar param=NULL;
fonction my_funct=NULL;


 my_map * gmap=NULL;
 my_map * gmap2=NULL;
 int test=0;
 int reg=0;
 int lconst=0;
 char recupIdent[100];
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
Prog            	:   DeclConst DeclVarPuisFonct {instarg("CALL",jump_label++);instarg("LABEL", 0);} SAVEGLOBAVAR {gmap=chargeFunctionToGmap(my_funct,gmap);} DeclMain
						;
DeclConst			:	DeclConst CONST ListConst PV
						|/*rien*/
					;
ListConst			:	 ListConst VRG IDENT EGAL Litteral {
															strcpy(ytype_auxi.name,$3);
															
															if(ytype_auxi.typey == ENTIER){
																
																if(lconst==0){
																	gmap=ajouter(gmap,"entier",ytype_auxi.name,"NULL",atoi(ytype_auxi.value),0,'c',depl,NULL);
																	depl++;		
															
																}else if(lconst==1){
																	gmap=ajouter(gmap,"entier",ytype_auxi.name,"NULL",atoi(ytype_auxi.value),0,'C',depl,NULL);
																	instarg("ALLOC",10);
																	sauvegardeEntier2(atoi(ytype_auxi.value),getAdresse(gmap,ytype_auxi.name));

																	depl++;	
																}

															}						
															else{
																printf("#\t\t %s\n\n",ytype_auxi.value);
																gmap=ajouter(gmap,"chaine",ytype_auxi.name,ytype_auxi.value,0,0,'c',depl,NULL);
																sauvegardeChaine(ytype_auxi.value);

															}
																

											  }
						| IDENT EGAL Litteral {
												strcpy(ytype_auxi.name,$1);
												if(ytype_auxi.typey == ENTIER){

													if(lconst==0){
													
													gmap=ajouter(gmap,"entier",ytype_auxi.name,"NULL",atoi(ytype_auxi.value),0,'c',depl,NULL);
													depl++;
													}else if(lconst==1){
														gmap=ajouter(gmap,"entier",ytype_auxi.name,"NULL",atoi(ytype_auxi.value),0,'C',depl,NULL);
														printf("#im inside %s %d %d \n",ytype_auxi.name,atoi(ytype_auxi.value),getAdresse(gmap,ytype_auxi.name));
														instarg("ALLOC",1);
														sauvegardeEntier2(atoi(ytype_auxi.value),getAdresse(gmap,ytype_auxi.name));
														affiche(gmap);
														depl++;	

													}
												}													
												else{
													gmap=ajouter(gmap,"chaine",ytype_auxi.name,ytype_auxi.value,0,0,'c',depl,NULL);
													sauvegardeChaine(ytype_auxi.value);

												}
													

											  }
						;
Litteral  			: 	NombreSigne
						| CHAINE 		
						;
NombreSigne			: 	NUM  { /* MODIF DU 25 04 2013*/
								ytype_auxi.typey=ENTIER; 
								sprintf(ytype_auxi.value,"%d",$1); 
								/*instarg("SET",$1);
								inst("PUSH");**/
						}    		
						| ADDSUB NUM	{/*conflit possible ici*/
											if($1=='-'){
												instarg("SET",$2);
												inst("NEG");                  						
		                   						inst("PUSH");
		                   					}
                   						}
						;
DeclVarPuisFonct 	:	 TYPE ListVar {putTypeInStorage(&ytype,$1);} PV DeclVarPuisFonct 
						| DeclFonct
						| /*rien*/
						;
ListVar				: 	ListVar VRG IDENT { 
											if(reg==0){
												AjoutStoreIdentValue(&ytype,$3);
											}
											else if(ytype_auxi.typey == ENTIER){
												gmap=ajouter(gmap,"entier",$3,NULL,0,0,'e',depl,NULL);
												instarg("ALLOC",1);
												depl++;
											}
											else
												gmap=ajouter(gmap,"chaine",$3,"NULL",0,0,'s',depl,NULL);
												

											}
						| IDENT {	
											if(reg==0){
												AjoutStoreIdentValue(&ytype,$1);
											}
											else if(ytype_auxi.typey == ENTIER){
												gmap=ajouter(gmap,"entier",$1,NULL,0,0,'e',depl,NULL);
												instarg("ALLOC",1);
												
												depl++;
											}
											else
												gmap=ajouter(gmap,"chaine",$1,"NULL",0,0,'s',depl,NULL);
												

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
EnTeteFonct			:	TYPE IDENT LPAR Parametres RPAR {printf("#=============\n");ajoutFonction(&my_funct,$2,$1,param); afficheFonction(my_funct);  freeListvar(&param);}
						| VOID IDENT LPAR Parametres RPAR { ajoutFonction(&my_funct,$2,"void",param);  freeListvar(&param);}
						;
Parametres			: 	VOID 
						| ListTypVar
						;
ListTypVar			: 	ListTypVar VRG TYPE IDENT { ajoutListvar(&param,$4,"0",$3);}
						| TYPE IDENT { ajoutListvar(&param,$2,"0",$1);}
						;
Corps				: 	LACC {lconst=1;} DeclConst {lconst=0;} DeclVar SuiteInstr RACC
						;
DeclVar 			: 	DeclVar TYPE { 

										
										if(strcmp($2,"entier")==0){
											comment("DECLARATION D ENTIER\n");
											ytype_auxi.typey = ENTIER;
										}
										else {
										comment("DECLARATION DE STRING\n");

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
Instr 				: 	LValue {strcpy(recupIdent,ytype_auxi.name);} EGAL Exp PV { 

											 if(ytype_auxi.typey==3){
												printf("#%s == %s\n",recupIdent,ytype_auxi.name);

												updateIdent(gmap,recupIdent,ytype_auxi.name);
												affiche(gmap);
												sauvegardeEntier2(getEntier(gmap,recupIdent),getAdresse(gmap,recupIdent));

											}
											else if(ytype_auxi.typey == STRING){
												comment("INITIALISATION D'UN STRING\n");
												gmap=ajouter(gmap,"chaine",ytype_auxi.name,ytype_auxi.value,0,0,'s',depl,NULL);
												
												/*sauvegardeChaine(ytype_auxi.value);*/


											}
											else{
												comment("INITIALISATION D'UN INT\n");
												gmap=ajouter(gmap,"entier",ytype_auxi.name,"NULL",atoi(ytype_auxi.value),0,'e',depl,NULL);
												


												sauvegardeEntier2(atoi(ytype_auxi.value),getAdresse(gmap,ytype_auxi.name));
												/*sauvegardeEntier(atoi(ytype_auxi.value));*/
												affiche(gmap);
											} 
								
								

						}
						| IF LPAR Exp RPAR FIXIF Instr %prec NELSE {instarg("LABEL",$5);} 
						| IF LPAR Exp RPAR FIXIF Instr ELSE FIXELSE { instarg("LABEL",$5);} Instr { instarg("LABEL",$8);}
						| WHILE ANCRE LPAR Exp RPAR  FIXIF Instr { instarg("JUMP", $2);instarg("LABEL",$6);}
						| RETURN Exp PV
						| RETURN PV
						| IDENT LPAR Arguments RPAR PV
						| READ LPAR IDENT RPAR PV { 
													/*instarg("ALLOC",1);*/
													printf("#ident=%s\n",$3);

													inst("READ");
													inst("SWAP");/*reg2=reg1*/
													instarg("SET",getAdresse(gmap,$3));/*reg1 =@de $3*/

													inst("SWAP");/*reg2 exchage reg1*/
													inst("SAVER"); /*sauver*/
													/*inst("SWAP");
													instarg("SET",depl);
													inst("SWAP");
													inst("SAVE");	*/
												}
						| READCH LPAR IDENT RPAR PV { 
													inst("READCH");
													inst("PUSH");
													}
						| PRINT {printf("#c bon \n");p=1;} LPAR Exp RPAR PV {
													printf("#et val vaut\n");
												  inst("POP"); 
                           						  inst("WRITE");
                           						  affiche(gmap);
                           						  p=0;
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
							if(p==1){
								
								chargerEntier(getAdresse(gmap,$1));
								p=0;
							}
						}
						| IDENT LSQB Exp RSQB {comment("DECLARATION D' UN TABLEAU\n");}
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
											
											if($3.my_type==3){
												sprintf($3.valeur,"%d",getEntier(gmap,$3.ident));
												chargerEntier(getAdresse(gmap,$3.ident));printf("#==> %d\n",getAdresse(gmap,$3.ident));
												
											}
											else{
												strcpy($3.valeur,$3.ident);
												instarg("SET",atoi($3.ident));
												inst("PUSH");
											}

											if($1.my_type==3){
												sprintf($1.valeur,"%d",getEntier(gmap,$1.ident));
												chargerEntier(getAdresse(gmap,$1.ident));printf("#==>%d\n",getAdresse(gmap,$1.ident));

											
											}
											else {
												strcpy($1.valeur,$1.ident);
												instarg("SET",atoi($1.ident));
												inst("PUSH");
											}



											inst("POP");
											inst("SWAP"); 
											inst("POP");

											if($2=='+'){
												
												/*libere_storeIdentValue(&ytype);*/
												AjoutStoreIdentValue(&ytype,"resultat");
												sprintf(ytype->name,"%d",atoi($3.valeur)+atoi($1.valeur));
												ytype->typey=ENTIER;
												sprintf(ytype->value,"%d",atoi($3.valeur)+atoi($1.valeur));

												inst("ADD");
												
											}else {
												/*libere_storeIdentValue(&ytype);*/
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

											if($3.my_type==3){
												sprintf($3.valeur,"%d",getEntier(gmap,$3.ident));
												chargerEntier(getAdresse(gmap,$3.ident));printf("#==> %d\n",getAdresse(gmap,$3.ident));
												
											}
											else{
												strcpy($3.valeur,$3.ident);
												instarg("SET",atoi($3.ident));
												inst("PUSH");
											}

											if($1.my_type==3){
												sprintf($1.valeur,"%d",getEntier(gmap,$1.ident));
												chargerEntier(getAdresse(gmap,$1.ident));printf("#==>%d\n",getAdresse(gmap,$1.ident));

											
											}
											else {
												strcpy($1.valeur,$1.ident);
												instarg("SET",atoi($1.ident));
												inst("PUSH");
											}
												
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
											test=1;
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

											if($3.my_type==3){
												sprintf($3.valeur,"%d",getEntier(gmap,$3.ident));
												chargerEntier(getAdresse(gmap,$3.ident));printf("#==> %d\n",getAdresse(gmap,$3.ident));
												
											}
											else{
												strcpy($3.valeur,$3.ident);
												
												instarg("SET",atoi($3.ident));
												inst("PUSH");



												printf("# \tval=%d  comp ",atoi($3.ident));
											}

											if($1.my_type==3){
												sprintf($1.valeur,"%d",getEntier(gmap,$1.ident));
												chargerEntier(getAdresse(gmap,$1.ident));printf("#==>%d\n",getAdresse(gmap,$1.ident));

											
											}
											else {
												printf("# val=%d\n",atoi($1.ident));
												
												strcpy($1.valeur,$1.ident);
												instarg("SET",atoi($1.ident));
												inst("PUSH");
												
											}


											
											
											inst("POP");
											inst("SWAP");
											
											inst("POP");


											if(strcmp("==",$2)==0){
												/*libere_storeIdentValue(&ytype);*/
												if(atoi($3.valeur)==atoi($1.valeur)){													
													AjoutStoreIdentValue(&ytype,$3.ident);
													ytype->typey=$3.my_type;
												}
												else{
													AjoutStoreIdentValue(&ytype,"0");
													ytype->typey=ENTIER;
												}
												inst("EQUAL");
											}
											else if(strcmp("!=",$2)==0){
												/*libere_storeIdentValue(&ytype);*/
												if(atoi($3.valeur)!=atoi($1.valeur)){													
													AjoutStoreIdentValue(&ytype,$3.ident);
													ytype->typey=$3.my_type;
												}
												else{
													AjoutStoreIdentValue(&ytype,"0");
													ytype->typey=ENTIER;
												}
												
												inst("NOTEQ");
											}
											else if(strcmp("<",$2)==0){
												/*libere_storeIdentValue(&ytype);*/

												if(min(atoi($3.valeur),atoi($1.valeur))==atoi($3.valeur)){
													AjoutStoreIdentValue(&ytype,$3.ident);
													ytype->typey=$3.my_type;
												}
												else{
													AjoutStoreIdentValue(&ytype,"0");
													ytype->typey=ENTIER;
												}

												inst("LOW");
											}
											else if(strcmp("<=",$2)==0){
												/*libere_storeIdentValue(&ytype);*/
												if(min(atoi($3.valeur),atoi($1.valeur))==atoi($3.valeur)){
													AjoutStoreIdentValue(&ytype,$3.ident);
													ytype->typey=$3.my_type;
												}
												else{
													AjoutStoreIdentValue(&ytype,"0");
													ytype->typey=ENTIER;
												}

												inst("LEQ");
											}
											else if(strcmp(">",$2)==0){
												/*libere_storeIdentValue(&ytype);*/
												if(max(atoi($3.valeur),atoi($1.valeur))==atoi($3.valeur)){
													
													AjoutStoreIdentValue(&ytype,$3.ident);
													ytype->typey=$3.my_type;
												}
												else{
													AjoutStoreIdentValue(&ytype,"0");
													ytype->typey=ENTIER;
												}
												affiche_storeIdentValue(ytype);
												inst("GREAT");
											}
											else if(strcmp(">=",$2)==0){
												/*libere_storeIdentValue(&ytype);*/
												if(max(atoi($3.valeur),atoi($1.valeur))==atoi($3.valeur)){
													
													AjoutStoreIdentValue(&ytype,$3.ident);
													ytype->typey=$3.my_type;
												}
												else{
													AjoutStoreIdentValue(&ytype,"0");
													ytype->typey=ENTIER;
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
												chargerEntier(getAdresse(gmap,$2.ident));printf("#==> %d\n",getAdresse(gmap,$2.ident));
											}
											else{

												strcpy($2.valeur,$2.ident);
												instarg("SET",atoi($2.ident));
												inst("PUSH");
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

											printf("#im inside now %d %d\n",atoi($1.valeur),atoi($3.valeur)); 
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

											if($3.my_type==3){
												sprintf($3.valeur,"%d",getEntier(gmap,$3.ident));
												chargerEntier(getAdresse(gmap,$3.ident));printf("#==> %d\n",getAdresse(gmap,$3.ident));
												
											}
											else{
												strcpy($3.valeur,$3.ident);
												instarg("SET",atoi($3.ident));
												inst("PUSH");
											}

											if($1.my_type==3){
												sprintf($1.valeur,"%d",getEntier(gmap,$1.ident));
												chargerEntier(getAdresse(gmap,$1.ident));printf("#==>%d\n",getAdresse(gmap,$1.ident));

											
											}
											else {
												strcpy($1.valeur,$1.ident);
												instarg("SET",atoi($1.ident));
												inst("PUSH");
											}

							
			
											inst("POP");	/* r1 = exp1*/
											inst("SWAP");	/* r2 = exp1 */
											inst("POP");    /* r1 = exp2 */
											inst("ADD");	/* r1 = exp1 + exp2 */
											inst("SWAP");	/* r2 = exp1 + exp2 */

											if(strcmp("&&",$2)==0){
												
											/*	libere_storeIdentValue(&ytype);*/
												AjoutStoreIdentValue(&ytype,"resultat");
												sprintf(ytype->name,"%d",atoi($3.valeur)&&atoi($1.valeur));
												ytype->typey=ENTIER;
												sprintf(ytype->value,"%d",atoi($3.valeur)&&atoi($1.valeur));
												
												instarg("SET",2); /* r1 = 2 */
												inst("SWAP");
												inst("GREAT");/* si r1 vaut 1 donc exp1=1 et exp2=1 le && est verifier . sinon le && n est pas verifier */

											}
											else {

												/*libere_storeIdentValue(&ytype);*/
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
											chargerEntier(getAdresse(gmap,$2.ident));printf("#==> %d\n",getAdresse(gmap,$2.ident));
										}
										else{

											strcpy($2.valeur,$2.ident);
											instarg("SET",atoi($2.ident));
											inst("PUSH");
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
						| LValue { $$.my_type=ytype_auxi.typey;printf("#je suis passe dans lvalue\n");p=1;}
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
						/*je vide ma liste ytype apres une instruction de controle ex: if(.....) et je vide*/
						libere_storeIdentValue(&ytype);

						inst("POP");
						instarg("JUMPF", $$=jump_label++);
					}
					;
FIXELSE :  			{
						libere_storeIdentValue(&ytype);

	  					instarg("JUMP", $$=jump_label++);
					 }
					 ;
ANCRE	:
  					{
  						instarg("LABEL",$$=jump_label++);
  					}
  					;
SAVEGLOBAVAR :		{
					printf("#je suis entree\n");
					storeGlobal();
					if(gmap!=NULL){
							while(gmap[reg].define!='f' && reg<TAILLE){

								if(getType(gmap,gmap[reg].ident)==ENTIER){
									instarg("ALLOC",1);
									sauvegardeEntier2(getEntier(gmap,gmap[reg].ident),getAdresse(gmap,gmap[reg].ident));
								}
								else{
									/*mettre ici la gestion des chaines global*/
								}
							reg++;
							}
						}	
						reg=1;
					}
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

void storeGlobal(){

  while(ytype!=NULL){
  		printf("#in storeg() depl =%d\n",depl);
    gmap=ajouter(gmap,"entier",ytype->name,NULL,0,0,'g',depl,NULL);
    printf("# %s @ vaut= %d\n",ytype->name,getAdresse(gmap,ytype->name));
  	/*instarg("ALLOC",1);*/
    depl++;
    ytype=ytype->next;
  }
  
}

void sauvegardeEntier(int valeur){
	printf("#depl=%d val =%d\n",tas,valeur);

  instarg("SET",tas);
  inst("SWAP");
  instarg("SET",valeur);
  inst("SAVER");
  
  tas++;
}

void sauvegardeEntier2(int valeur,int adresse){
	printf("#adresse=%d val =%d\n",adresse,valeur);

  instarg("SET",adresse);
  inst("SWAP");
  instarg("SET",valeur);
  inst("SAVER");
  
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
  inst("LOADR"); /* Palce dans reg1 la valeur situé à l adresse reg1 */
  inst("PUSH"); /* on le remet en tete de pile (pas forcément necessaire) */
}

void chargerEntierTAS(int adresse){
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
  instarg("ALLOC",500);
  yyparse();
  endProgram();
  return 0;
}






