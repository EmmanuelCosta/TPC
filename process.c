
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
/*retourne 0 si identifiant existe deja */
/* ou la position de la premiere case dispo dans la map*/
int exist(my_map m[TAILLE],char *ident){
  int i,j;
  for(i=0;i<TAILLE;i++){
    /*si definie et de type valeur*/

    if(m[i].define=='t' && strcmp(m[i].ident,ident)==0 && m[i].typevallex=='v')
        return 0;
      /*si definie et de type tableau*/
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

void affiche(my_map *map){
  int i=0;
  int j;
  for(i=0;i<TAILLE;i++){
     if(map[i].define=='t'){
        if(map[i].typevallex=='v')
          printf("posi = %d %s %s %d\n",i,map[i].type,map[i].ident,map[i].vallex.val );
        else
          printf("posi =%d l'id : %s est  un tableau de %s de taille %d dont les valeurs sont:\n",i,map[i].ident,map[i].type,map[i].vallex.tab.taille );
          for(j=0;j<map[i].vallex.tab.pos;j++){
            printf("--> i=%d %d  j=%d",i,map[i].vallex.tab.tab[j],j);
             printf("\n");
          }
         
    }
  }
  return;
}

int main(void){
  my_map *m=NULL;
m=ajouter(m,"boolean","sep",2,2);
m=ajouter(m,"boolean","sep",1,2);

m=ajouter(m,"entier","coola",1,0);

  affiche(m);
  
  return 0;
}

