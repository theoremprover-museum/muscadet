// Copyright 2008 Crip5 Dominique Pastre

#include <string.h>
#include <stdio.h>
main(argc,argv)
int argc;
char *argv[];

{ char cmd[256]; // to build the command (string)
                 // the executable is included in the number of arguments
  strcpy(cmd,"/usr/bin/swipl -f muscadet-en -g true ");
  if (argc >= 2 ) {
    strcat(cmd," <<! 2> /dev/null \n tptp(["); // tptp(
    int i;
    strcat(cmd,"'");                           //      '
    strcat(cmd,argv[1]);                       //       problem ou path
    strcat(cmd,"'");                           //                         '
    for (i=2;i<argc;i++) {                
       strcat(cmd, ",");                       //                          ,
       strcat(cmd, argv[i]);                   //       other arguments
       }
    strcat(cmd, "]). \n halt. \n ! ");         //            ]).
                                               //       alt.
                                               //       !
                                               //       .
    printf("\ngenerated command : \n%s\n",cmd);            
    }
  else  strcpy(cmd, "more tptp-commands");
  system(cmd); // to run the command             
  return;
				      
}





