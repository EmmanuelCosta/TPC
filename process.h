#ifndef DEF_PROCESS_H
#define DEF_PROCESS_H

#include<stdio.h>
#include<string.h>
#include<stdlib.h>

#define TAILLE 1024

typedef struct _tableau_{
	int *tab;
	int pos;
	int taille;
}tableau;
 
typedef struct _map_{
   union vallex{	
 	 int val;
 	 tableau tab;
  }vallex;
  char *type;
  char *ident;
  char define;
  int adresse;
  char typevallex; /*v pour union entier ou t pour tableau ou n not define*/

}my_map;


my_map* alloue_map(char* type,char *ident,int v,int taille);
int exist(my_map m[TAILLE],char *ident);
my_map* ajouter(my_map *map,char* type,char *ident,int v,int taille);
void affiche(my_map *map);
float getValue(my_map *m,char* ident);
void setValue(my_map *m,char *ident,float val);
void sup(my_map* m,char *id1,char *id2);
void inf(my_map* m,char *id1,char *id2);
void egal(my_map* m,char *id1,char *id2);
void testBooleanExpression(my_map*m,float v1,int op,float v2,char *id1,char *id2);
#endif