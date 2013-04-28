
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
my_map* alloue_map(char* type,char *ident,char *valchaine,int v,int taille,char typesup){
   int i=0;
   /*allocation de la map*/
  my_map *m=(my_map*)malloc(sizeof(my_map)*TAILLE);
  /*remplit le champs defint a false*/
   for(i = 0;i<TAILLE;i++){
    m[i].define='f';
    m[i].typevallex='n';

   }
   
  if( taille == 0 && typesup == 'c'){
    strcpy(m[0].vallex.val_chaine,valchaine);
    m[0].typevallex='s';

  }else if(taille == 0 && typesup == 'e'){
    m[0].vallex.val=v;
    m[0].typevallex='v';
  }else{
    m[0].vallex.tab=alloue_tableau( taille, v);
    m[0].typevallex='t';

  }
    strcpy(m[0].type,type);
    strcpy(m[0].ident,ident);
    m[0].define='t';

    return m;

}

#if 0
/*retourne 0 ou si tableau plein si identifiant existe deja */
/* ou la position de la premiere case dispo dans la map*/
int exist(my_map m[TAILLE],char *ident){
  int i,j;
  for(i=0;i<TAILLE;i++){
    /*si definie est de type valeur*/

    if(m[i].define=='t' && strcmp(m[i].ident,ident)==0 && m[i].typevallex!=='v')
        return 0;
      /*si definie est de type tableau*/
     else if(m[i].define=='t' && strcmp(m[i].ident,ident)==0 && m[i].typevallex=='t'){
      /*si tableau plein*/
       if(m[i].vallex.tab.pos==m[i].vallex.tab.taille)
        return 0;
        else 
          return m[i].vallex.tab.pos;/*>=1*/
        
      }
      else if(m[i].define=='f' ){
        /*si c 1 je donne -1 pour eviter confusion*/
            if(i==0){
              return -1;
            }
            return i;

      }
  }
   if(i==0)
    return -1;
  return i;
}

/*ajoute un identifiant dans la table des symboles*/

my_map* ajouter(my_map *map,char* type,char *ident,char *valchaine,int v,int taille,char type){
  int k;
  if(map==NULL){
      map=alloue_map(type,ident,valchaine, v,taille);
       return map;
  }
  k=exist(map,ident);
  printf("%d\n",k );
  if(k==0){
    printf("cet identifiant existe deja %d ou le tableaude valeur est plein \n", k);
    /*gerer les erreurs*/
    return map;  
  }
  if(k>=TAILLE){
    printf("TABLE DE SYMBOLE PLEINE\n");
    return map;
  }
  int i=0;
  int j;
  for(i=0;i<TAILLE;i++){

    if(map[i].define=='f' ||  map[i].typevallex=='t' ){
        if(taille==0 && map[i].define=='f'){
          map[i].vallex.val=v;
          map[i].typevallex='v';

        strcpy(map[i].type,type);
        strcpy(map[i].ident,ident);
        map[i].define='t';
        return map;
        }
        else if(taille!=0){
          if(k==1 && map[i].typevallex!='t' ){
            map[i].vallex.tab=alloue_tableau(taille,v);
             
                map[i].typevallex='t';
            strcpy(map[i].type,type);
            strcpy(map[i].ident,ident);
            map[i].define='t';
          }
          else{
                printf("k=%d i=%d\n",k ,i);
             map[i].vallex.tab.tab[k]=v;
             printf("k=%d\n",k );
             map[i].vallex.tab.pos++;
             map[i].typevallex='t';


          }
          return map;
        }
        
         
        
    }
   
  }
   printf("TAILLE TABLEAU INSUFFISANT\n");
   return map;
}
#endif

void affiche(my_map *map){
  int i=0;
  int j;
  if(map == NULL){printf("la map est NULL\n");}
  for(i=0;i<TAILLE;i++){
     if(map[i].define=='t'){
        if(map[i].typevallex=='v')
          printf("position = %d %s %s %d\n",i,map[i].type,map[i].ident,map[i].vallex.val );
          else if(map[i].typevallex =='s'){
              printf("position = %d %s %s %s\n",i,map[i].type,map[i].ident,map[i].vallex.val_chaine);
          }

          else{
          printf("position =%d l'id : %s est  un tableau de %s de taille %d dont les valeurs sont:\n",i,map[i].ident,map[i].type,map[i].vallex.tab.taille );
          for(j=0;j<map[i].vallex.tab.pos;j++){
            printf("--> i=%d %d  j=%d",i,map[i].vallex.tab.tab[j],j);
             
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
    printf("look : %s < == > %s \n",ident,type);
    /*si ident trouver */
    
    for(i=0;i<TAILLE;i++){
      if(strcmp(m[i].ident,ident)==0){
        if(m[i].typevallex=='v'){
              printf("looker entier : %s < == > %s \n",ident,type);

          if(strcmp("entier",type)==0)
            return i;
          else return -2;
        }else if(m[i].typevallex=='s'){
                        printf("looker string : %s < == > %s \n",ident,type);

          if(strcmp("chaine",type)==0 )           
            return i;
          else
            return -2;
          
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

my_map * ajouter(my_map *map,char* type,char *ident,char *valchaine,int v,int taille,char typesup){
  int i=0,j,k;

  if(map == NULL){

      map=alloue_map(type,ident,valchaine, v,taille, typesup);
       return map; 
  }
  k=exist2(map,ident,type);
  
  if(k == -2){
    printf("Cette identifiant a deja ete declare avec un autre type\n");
    return map;
  }
  if( k != -1){
    if(taille==0 && typesup=='e')
    return updateEntier(map,v,k);
  else if(taille==0)
    return updateString(map,valchaine,k);
  }
  
  
  /* rechercher d'une case libre */
  while(map[i].define != 'f'){
    i++;
  }
  if(i>= TAILLE){
    fprintf(stderr,"TABLE DES SYMBOLES PLEINE\n");
    return map;
  }

  /* ici je suis a la bonne case */
    if(taille == 0)
    {
   

          if(strcmp("entier",type) == 0)
          {
            strcpy(map[i].type,type);
            strcpy(map[i].ident,ident);
            map[i].typevallex = 'v';
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

my_map* updateEntier(my_map *map,int v,int k){  
  map[k].vallex.val = v;
  return map;

}

my_map* updateString(my_map *map,char* valchaine,int k){
  int i=0;
  
  
  strcpy(map[k].vallex.val_chaine,valchaine);

  return map;

  }
 
 #if 0 
my_map* updateTab(my_map *map,int v,int k,int indice){


}
int main(void){
 my_map *m=NULL;
 my_map *s=NULL;

s=ajouter(s,"entier","id",NULL,5,0,'e');
s=ajouter(s,"chaine","a1","aaaa",0,0,'c');
s=ajouter(s,"chaine","pos","aa",0,0,'c');
 
 printf(" %s %s %s\n\n",s[1].type,s[1].vallex.val_chaine,s[1].ident);
s=ajouter(s,"chaine","a1","bb",0,0,'c');
 printf(" %s %s %s\n\n",s[1].type,s[1].vallex.val_chaine,s[1].ident);
s=ajouter(s,"entier","id",NULL,15,0,'e');

 /* affiche(s);
 update(s,"a1",0,0,"b","chaine");
 update(s,"id",19,0,NULL,"entier");
 printf("********************\n\n");
 affiche(s);*/
  return 0;
}

#endif