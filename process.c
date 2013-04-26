
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
my_map* alloue_map(char* type,char *ident,int v,int taille){
   int i=0;
  my_map *m=(my_map*)malloc(sizeof(my_map)*TAILLE);
   for(i=0;i<TAILLE;i++){
     m[i].define='f';
      m[i].typevallex='v';
   }
   
  if(taille==0){
    m[0].vallex.val=v;
    m[0].typevallex='v';
  }
  else
  {
    m[0].vallex.tab=alloue_tableau( taille, v);
    

     m[0].typevallex='t';
     
  }
   m[0].type=malloc(sizeof(char)*(strlen(type)+1));
   strcpy(m[0].type,type);
  m[0].ident=malloc(sizeof(char)*(strlen(ident)+1));

   strcpy(m[0].ident,ident);
   
   m[0].define='t';

   return m;

}

#if 0
/*retourne 0 si identifiant existe deja */
/* ou la position de la premiere case dispo dans la map*/
int exist(my_map m[TAILLE],char *ident){
  int i,j;
  for(i=0;i<TAILLE;i++){
    /*si definie est de type valeur*/

    if(m[i].define=='t' && strcmp(m[i].ident,ident)==0 && m[i].typevallex=='v')
        return 0;
      /*si definie est de type tableau*/
     else if(m[i].define=='t' && strcmp(m[i].ident,ident)==0 && m[i].typevallex=='t'){
      /*si tableau plein*/
       if(m[i].vallex.tab.pos==m[i].vallex.tab.taille)
        return 0;
        else 
          return m[i].vallex.tab.pos;/*>=1*/
        
      }
      /*vu que val dans tableau contigue jarrete des que non defini*/
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
my_map* ajouter(my_map *map,char* type,char *ident,int v,int taille){
  int k;
  if(map==NULL){
      map=alloue_map(type,ident,v,taille);
       return map;
  }
  k=exist(map,ident);
  printf("%d\n",k );
  if(k==0){
    printf("cet identifiant existe deja %d \n", k);
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

        map[i].type=malloc(sizeof(char)*(strlen(type)+1));
        strcpy(map[i].type,type);
        map[i].ident=malloc(sizeof(char)*(strlen(ident)+1));
        strcpy(map[i].ident,ident);
        map[i].define='t';
        return map;
        }
        else if(taille!=0){
          if(k==1 && map[i].typevallex!='t' ){
            map[i].vallex.tab=alloue_tableau(taille,v);
             
                map[i].typevallex='t';
            map[i].type=malloc(sizeof(char)*(strlen(type)+1));
            strcpy(map[i].type,type);
            map[i].ident=malloc(sizeof(char)*(strlen(ident)+1));
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
/**************************************update map **************************************************************/

int exist2(my_map m[TAILLE],char *ident,char *type){
    
    int i=0;
    int j;
    if(strcmp("entier",type)==0 ){
      for(i=0;i<TAILLE;i++){
        if(m[i].typevallex=='v'){
          if(strcmp(m[i].ident,ident)==0){
              return i;
          }
        }
        
      }
    }
    else if( strcmp("chaine",type)==0){
      for(i=0;i<TAILLE;i++){
        if(m[i].typevallex=='s'){
          if(strcmp(m[i].ident,ident)==0){            
            return i;
          }
        }
        
      }
    
    }
    #if 0
    else {
      for(i=0;i<TAILLE;i++){
          if(strcmp(m[i].ident,ident)==0 && m[i].typevallex=='t'){

          }
      }
    
    }
    #endif

    return -1;

}

my_map * ajouter2(my_map *map,char* type,char *ident,int v,char *nom_chaine,int taille){
  int k;
  int i=0,j;
  if(map==NULL){

      map=alloue_map(type,ident,v,taille);
       return map; 
  }
  k=exist2(map,ident,type);
  

  if( k != -1){
    printf(" this element is already exist \n");
    return map;
  }
  if(k>= TAILLE){
    fprintf(stderr,"TABLE DES SYMBOLES PLEINE\n");
    return map;
  }
  
  /* rechercher d'une case libre */
  while(map[i].define != 'f'){
    i++;
  }
  

  /* ici je suis a la bonne case */
    if(taille == 0)
    {
   

          if(strcmp("entier",type) == 0)
          {
            map[i].type=malloc(sizeof(char)*(strlen(type)+1));
            strcpy(map[i].type,type);
            map[i].ident=malloc(sizeof(char)*(strlen(ident)+1));
            strcpy(map[i].ident,ident);
            map[i].typevallex = 'v';
            map[i].vallex.val = v;
            map[i].define='t';
           
            return map;
          }
          else
          {


           map[i].type=malloc(sizeof(char)*(strlen(type)+1));
            strcpy(map[i].type,type);
            map[i].ident=malloc(sizeof(char)*(strlen(ident)+1));
            strcpy(map[i].ident,ident);
            map[i].typevallex = 's';
            strcpy(map[i].vallex.val_chaine,nom_chaine);
            map[i].define='t';
            
            return map;

          }
        


    }
    return map; 

}

void update(my_map *map,char *ident,int v,int taille,char * name,char*type){
  int k=0;
  if(map == NULL){
    fprintf(stderr," la map est vide (update_int ) \n");
    return  ;
  }

  k= exist2(map,ident,type);
  
  if(strcmp(type,"entier")==0){
      if( k != -1 && taille==0){
       
                map[k].ident=malloc(sizeof(char)*(strlen(ident)+1));
                strcpy(map[k].ident,ident);
                map[k].vallex.val = v;
                return ;
      }
      else{
        printf(" L'entier n'existe pas\n");
        return;
      }

  }
  else if(strcmp(type,"chaine")==0){
      if( k != -1 ){

        map[k].ident=malloc(sizeof(char)*(strlen(ident)+1));
        strcpy(map[k].ident,ident);
        strcpy(map[k].vallex.val_chaine,name);
        return ;
      }else{
        printf(" La chaine n'existe pas\n");
        return;
  
      }
  }      


}
/*
int main(void){
 my_map *m=NULL;
 my_map *s=NULL;

s=ajouter2(s,"entier","id",5,NULL,0);
s=ajouter2(s,"chaine","a1",0,"aaaa",0);
s=ajouter2(s,"chaine","pos",0,"aa",0);
 
  affiche(s);
 update(s,"a1",0,0,"b","chaine");
 update(s,"id",19,0,NULL,"entier");
 printf("********************\n\n");
 affiche(s);
  return 0;
}
*/
