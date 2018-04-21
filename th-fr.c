// Copyright 2008 Crip5 Dominique Pastre

#include <string.h>
#include <stdio.h>
#include <stdlib.h>
void main(argc,argv)
int argc;
char *argv[];

{ char cmd[256]; // pour construire la commande (chaine de caracteres)
  strcpy(cmd,"/usr/bin/swipl -f muscadet-fr -g true ");
  if (argc >= 2 ) {
    strcat(cmd," <<! 2> /dev/null \n th(["); // th(
    int i;
    strcat(cmd,"'");                           //      '
    strcat(cmd, argv[1]);                      //       fichier ou chemin
    strcat(cmd,"'");                           //                         '
    for (i=2;i<argc;i++) {                
       strcat(cmd, ",");                       //                          ,
       strcat(cmd, argv[i]);                   //       autres arguments
       }
    strcat(cmd, "]). \n halt. \n ! .");         //            ]).
                                               //  alt.
                                               //       ! 
                                               //   .
    printf("\ncommande generee : \n%s\n",cmd);            
    }
  else  strcpy(cmd, "more th-commandes");
  system(cmd); // pour executer la commande             
  return;
				      
}





