
#include"process.h"

tableau alloue_tableau(int taille,int v){
  tableau tabl;
  int i;
  tabl.pos=1;
  tabl.taille=taille;
  tabl.tab=(int *)malloc(sizeof(int)*taille);
    tabl.tab[0]=v;
  for(i=1;i<taille;i++)
    tabl.tab[i]=0;
  return tabl;
}
/*type e pour entier c pour chaine et t tableau*/
my_map* alloue_map(char* type,char *ident,char *valchaine,int v,int taille,char typesup,listvar var){
   int i=0;
   /*allocation de la map*/
  my_map *m=(my_map*)malloc(sizeof(my_map)*TAILLE);
  /*remplit le champs defint a false*/
   for(i = 0;i<TAILLE;i++){
    m[i].define='f';
    m[i].typevallex='n';
    m[i].adresse = -1;

   }   
    m[0].typevallex=typesup; 
   if( taille == 0 && strcmp(type,"chaine")==0){
    printf("#\t\t\tinit\n");
    strcpy(m[0].vallex.val_chaine,valchaine);

  }else if(taille == 0 && strcmp(type,"entier")==0){
     printf("#\t\t\tinit2\n");
    m[0].vallex.val=v;

  }else{
    m[0].vallex.var=var;

  }
    strcpy(m[0].type,type);
    strcpy(m[0].ident,ident);
    m[0].define='t';
     m[0].adresse = 0;
    return m;

}



void affiche(my_map *map){
  int i=0;
  int j;
  if(map == NULL){printf("#la map est NULL\n");}
  for(i=0;i<TAILLE;i++){
     if(map[i].define=='t'){
        if(map[i].typevallex=='e' ||((map[i].typevallex=='c' || map[i].typevallex=='g'|| map[i].typevallex=='C')&& strcmp("entier",map[i].type)==0 ) )
          printf("#position = %d %s %s %d ==adresse = %d  == %c\n",i,map[i].type,map[i].ident,map[i].vallex.val,map[i].adresse,map[i].typevallex );
          else if(map[i].typevallex =='s' || ((map[i].typevallex=='c' || map[i].typevallex=='C')&& strcmp("chaine",map[i].type)==0 ) ){
              printf("#position = %d %s %s %s\n",i,map[i].type,map[i].ident,map[i].vallex.val_chaine);
          }

          else{
          printf("#position =%d l'id : %s est  un tableau de %s de taille %d dont les valeurs sont:\n",i,map[i].ident,map[i].type,map[i].vallex.tab.taille );
          for(j=0;j<map[i].vallex.tab.pos;j++){
            printf("#--> i=%d %d  j=%d",i,map[i].vallex.tab.tab[j],j);
             
             printf("\n");
           }
          }
          
         
    }
  }
  return;
}

char * recupe_chaine(char * chaine){

    int i =1;
    int j =0;
    int k = strlen(chaine);
    char * new =(char*)malloc(sizeof(char)*(k-1));
    for(j=0;j<k-2;j++){
      new[j] = chaine[i];
      i++;
    }
      
    return new;
}

/* -1 non existant 
*  -2 erreur de typage
* autre valeur = existence 
******/
int exist2(my_map m[TAILLE],char *ident,char *type){
    
    int i=0;
    /*si ident trouver */
    for(i=0;i<TAILLE;i++){


      if(strcmp(m[i].ident,ident)==0){
        if(m[i].typevallex=='e'){

          if(strcmp("entier",type)==0)
            return i;
          else return -2;
        }else if(m[i].typevallex=='s'){

          if(strcmp("chaine",type)==0 )           
            return i;
          else
            return -2;
          
        }else if(m[i].typevallex=='c' || m[i].typevallex=='C'){
         return -3;
          
        }else if(m[i].typevallex=='g'){

         return i;
          
        }else {
          if(m[i].typevallex=='t'){
            if(strcmp("entier",type)==0)
             return i;
            else return -2;
          }
        }

       }
    }


    return -1;
 }


/*ajouter gestion des variables non initialisees*/
my_map * ajouter(my_map *map,char* type,char *ident,char *valchaine,int v,int taille,char typesup,int adresse,listvar var){
  int i=0,k;

 
  if(map == NULL){
      map=alloue_map(type,ident,valchaine, v,taille, typesup,var);
      map[0].adresse = adresse;
       return map; 
  }
  k=exist2(map,ident,type);
  if(k == -2){
    printf("\n#Cette identifiant a deja ete declare avec un autre type\n");
    perror("#\nidentifiant existant \n");
    exit(0);
  }
  if(k==-3){
    printf("#Cette identifiant est une constante et ne peut pas etre modifie\n");
    perror("\n#identifiant declare comme constante ne peut etre redeclare\n");
    exit(0);
  }
   
  if( k != -1){
    if(taille==0 && (typesup=='e' || typesup=='g')){
       return updateEntier(map,v,k,adresse);

    }
             
    else if(taille==0) {
       return updateString(map,valchaine,k,adresse);
    } 
     
  
  }
  
  
  /* rechercher d'une case libre */
  while(map[i].define != 'f'){
    i++;
  }
  if(i>= TAILLE){
    fprintf(stderr,"TABLE DES SYMBOLES PLEINE\n");
    return map;
  }
  if(map[i].adresse == -1){
    map[i].adresse = adresse;
  }
      

  /* ici je suis a la bonne case */
    if(taille == 0)
    {
            map[i].typevallex = typesup;
       
          if(strcmp("entier",type) == 0)
          {
            strcpy(map[i].type,type);
            strcpy(map[i].ident,ident);
            
           
            map[i].vallex.val = v;
            map[i].define='t';

           
            return map;
          }
          else
          {


            strcpy(map[i].type,type);
            strcpy(map[i].ident,ident);
            map[i].typevallex = 's';
            strcpy(map[i].vallex.val_chaine,valchaine);
            map[i].define='t';
            
            return map;

          }
        


    }
    else{
      map[i].vallex.tab=alloue_tableau(taille, v);
      strcpy(map[i].type,type);
      strcpy(map[i].ident,ident);
      map[i].typevallex='t';
    }
    return map; 

}

my_map* updateEntier(my_map *map,int v,int k,int adresse){  
  map[k].vallex.val = v;
  return map;

}

my_map* updateString(my_map *map,char* valchaine,int k,int adresse){
    
  
  strcpy(map[k].vallex.val_chaine,valchaine);

  return map;

  }
/*utilise pour modifier la valeur dun identifiant
*en fonction dun autre ident
****/
 void updateIdent(my_map*map,char *cible,char *source){
    int i=0;
    int t;
    if(map == NULL){
      perror("la map ne peut etre nulle lors dune mise a jour");
      exit(0);
    }
      
    t=getType(map,cible);
    if(t!=getType(map,source)){
      perror("AFFECTATION DANS IDENTIFIANT DE TYPE DIFFERENT");
      exit(0);
    }
    while(i<TAILLE && strcmp(cible,map[i].ident)!=0)
      i++;

    if(t == ENTIER){
        map[i].vallex.val=getEntier(map,source);
    }
    else
        strcpy(map[i].vallex.val_chaine,getString(map,source));

   }
  int getType(my_map * map,char * ident){
    int i = 0;
  for(i=0;i<TAILLE;i++){
      if(strcmp(map[i].ident,ident)==0){
/*printf("# lid = %s vaut %c\n",ident,map[i].typevallex);*/
          if(strcmp(map[i].type,"entier")==0)
             return ENTIER;
           else return STRING;
      }
  }
  return -2;

  }


 
 int getEntier(my_map * map,char * ident){
  int i = 0;
  for(i=0;i<TAILLE;i++){
      if(strcmp(map[i].ident,ident)==0){

        return map[i].vallex.val;
      }
  }
  return -2;
} 

char * getString(my_map * map,char * ident){

  int i = 0;
  for(i=0;i<TAILLE;i++){
    if(strcmp(map[i].ident,ident)==0){
      return map[i].vallex.val_chaine;
    }
  }  
  return NULL;
}
 
/************************MODULE DE LISTE ***************************************************/


storeIdentValue  AllocationStoreIdentValueInit(void){

  storeIdentValue  new=(storeIdentValue)malloc(sizeof(_storeIdentValue));
  if(new != NULL){
      new->next = NULL;
      return new;
    }
    
  
  return NULL;  
  
}
storeIdentValue  AllocationStoreIdentValue(char *name){

  storeIdentValue  new=(storeIdentValue)malloc(sizeof(_storeIdentValue));
  if(new != NULL){
      strcpy(new->name,name);
      new->next = NULL;
      return new;
    }
    
  
  return NULL;  
  
}

/**en tete*/
void AjoutStoreIdentValue(storeIdentValue * l,char * name){

  storeIdentValue new=AllocationStoreIdentValue(name);
  storeIdentValue courant; 
  courant = *l;
  if(*l==NULL ){

  *l=new;
  return;
  }
  new->next=courant;
  *l =new;
 

}

void affiche_storeIdentValue(storeIdentValue liste){ 
  storeIdentValue courant; 
  courant = liste; 
  while (courant != NULL){ 
      printf ("## %s of type %d  ", courant->name,courant->typey); 
      courant = courant->next; 
  } 
    printf("\n");
}

storeIdentValue  ExtraitTete(storeIdentValue *l){
  if(*l == NULL)
      return NULL;
  /*char * n =malloc(sizeof(char)*(strlen((*l)->name)+1));*/
  /**strcpy(n,(*l)->name);*/
  storeIdentValue courant=*l; 
  *l=(*l)->next;
  courant->next=NULL;
  return courant;

}

void libere_storeIdentValue(storeIdentValue *l){
  if(*l == NULL)
      return ;
    printf("#aavant seg\n");
  storeIdentValue courant; 
  while(*l!=NULL){
    courant=*l; 
    *l=(*l)->next;
    free(courant);
  }
  *l=NULL;
printf("#aapres seg\n");
}

int getAdresse(my_map * map,char *ident){

  int i = 0;
  for(i=0;i<TAILLE;i++){
    if(strcmp(map[i].ident,ident)==0){
      return map[i].adresse;
    }
  }
  return -1;
}

void putTypeInStorage(storeIdentValue *ytype,char* name){
  if(ytype==NULL) return;
  storeIdentValue courant=*ytype;
  while(courant!=NULL){
    if(strcmp(name,"entier")==0)
    courant->typey=ENTIER;
    else
       courant->typey=STRING;
    courant=courant->next;
  }
  
}
/***************MODULE DE CONTROLE ***********************/
int max(int a,int b){
  if(a>b)
    return a;
  return b;
}

int min(int a,int b){
  if(a<b)
    return a;
  return b;
}


struct _listvar_ * alloueListvar(char *name,char*value,int type){
  listvar var=(listvar)malloc(sizeof(struct _listvar_));
  if(var ==NULL){
    printf("error in allocation\n");
    return NULL;
  }
  var->type=type;
  var->name=malloc(sizeof(char)*(strlen(name)));
  var->value=malloc(sizeof(char)*(strlen(value)));
  strcpy(var->name,name);

  strcpy(var->value,value);
  var->next=NULL;
  return var;
}

void ajoutListvar(listvar *var,char *name,char*value,int type){
  struct _listvar_ * temp;
  if(*var==NULL){
    *var= alloueListvar(name,value,type);
    return;
  }
  temp=*var;
  while(temp->next!=NULL){
    temp=temp->next;
  }
  temp->next= alloueListvar(name,value,type);
}

char * getVar(listvar var,char *name){
  if(var==NULL){
    printf("There isn' t any internal variable \n");
    return NULL;
  }
  while(var!=NULL){
    if(strcmp(var->name,name)==0)
      return var->value;
    var=var->next;
  }
  printf("The variable needed doesn 't exist yet \n");
  return NULL;
}

/*
int main(int argc, char *argv[])
{
  storeIdentValue a = NULL;
    AjoutStoreIdentValue(&a,"ra");
  printf("ExtraitTete = %s\n\n",ExtraitTete(&a));

  AjoutStoreIdentValue(&a,"ko");
  AjoutStoreIdentValue(&a,"ton");
  affiche_storeIdentValue(a);
    printf("ExtraitTete = %s\n\n",ExtraitTete(&a));

  AjoutStoreIdentValue(&a,"ton");
  affiche_storeIdentValue(a);

  return 0;
}
*/