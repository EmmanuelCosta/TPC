#ifndef DEF_PROCESS_H
#define DEF_PROCESS_H

#include<stdio.h>
#include<string.h>
#include<stdlib.h>
#include <unistd.h>

#include <string.h>


#define TAILLE 1024
#define N 100

typedef struct _listvar_ {
  char * name ;
  char * value ;
  int type;
  struct  _listvar_ *next;
 }_listvar,*listvar;


  enum{
    STRING,ENTIER
  }typage;

   

typedef struct _storeIdentValue_{
    int typey;
    char  value[100];
    char  name[100] ;  
    struct _storeIdentValue_ * next;
  }_storeIdentValue, *storeIdentValue;


typedef struct _storeIdentValueAuxi_{
    int typey;
    char  value[100];
    char  name[100] ;  
  }storeIdentValueAuxi;



typedef struct typeExp_{
    int my_type;
    char valeur[100];
      char ident[100];

  }TYPEEXP;

/* structure de gmap*/
typedef struct _tableau_{
	int *tab;
	int pos;
	int taille;
}tableau;
 
typedef struct _map_{
   union vallex{	
 	 int val;
 	 tableau tab;
   char  val_chaine[2*N];
   listvar var;
  }vallex;
  char type[N];
  char ident[N];
  char define;
  int adresse;
  char typevallex; /*v pour union entier ou t pour tableau  s pour string ou n not define c const global,g pour var gobal qlconque*/

}my_map;



typedef struct _typeexp_{
  union type{
    int entier;
    char *chaine;
  }type;

}TYPE_EXP;
/*************************************/


my_map* alloue_map(char* type,char *ident,char *valchaine,int v,int taille,char typesup,listvar var);
int exist(my_map m[TAILLE],char *ident);
my_map* ajouter(my_map *map,char* type,char *ident,char *valchaine,int v,int taille,char typesup,int adresse,listvar var);
void affiche(my_map *map);
my_map* updateEntier(my_map *map,int v,int k,int adresse);
my_map* updateString(my_map *map,char* valchaine,int k,int adresse);
float getValue(my_map *m,char* ident);
void setValue(my_map *m,char *ident,float val);
void sup(my_map* m,char *id1,char *id2);
void inf(my_map* m,char *id1,char *id2);
void egal(my_map* m,char *id1,char *id2);
void testBooleanExpression(my_map*m,float v1,int op,float v2,char *id1,char *id2);
char * recupe_chaine(char * chaine);

void AjoutStoreIdentValue(storeIdentValue * l,char * name);
void affiche_storeIdentValue(storeIdentValue liste);
storeIdentValue ExtraitTete(storeIdentValue *l);
storeIdentValue  AllocationStoreIdentValueInit(void);
  int getType(my_map * map,char * ident);
 int getEntier(my_map * map,char * ident);

char * getString(my_map * map,char * ident);

int max(int a,int b);

int min(int a,int b);
void libere_storeIdentValue(storeIdentValue *l);
int getAdresse(my_map * map,char *ident);
void putTypeInStorage(storeIdentValue *ytype,char* name);
 void updateIdent(my_map*map,char *cible,char *source);

/***gestion des fonctions***/
 struct _listvar_ * alloueListvar(char *name,char*value,int type);
void ajoutListvar(listvar *var,char *name,char*value,int type);
void afficheListvar(listvar var);
char * getVar(listvar var,char *name);
  

#endif