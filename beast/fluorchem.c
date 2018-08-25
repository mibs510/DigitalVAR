#include <stdio.h>
#include <stdlib.h>
#include <signal.h>

// To compile: gcc -Wall -o fluorchem fluorchem.c
// Written by: Connor McMillan

void stop(int signum){
	printf("Exiting...");
	exit(signum);
}

int main(int argc, char *argv[]){
  signal(SIGTERM, stop);
  char command[128];
  char IMG[] = "fluorchem-mfg-master-2017-11-27";
  char XXHSUM[] = "ade06eeaf7bcad46";
  

  if ( argc <= 3 ){
    printf("ERROR: Not enough arguments.\n");
	  printf("You need to image at least 3 drives.\n");
	  printf("%s [target] [target] [target] [target] ...\n", argv[0]);
	  printf("Example: %s a b c d e f g h i j k l\n", argv[0]);
    printf("Where IMG=%s\n", IMG);
    return 1;
  }
  
  printf("\n\n\nBE SURE %s IS YOUR MASTER IMAGE!!\n\n\n", IMG);
  printf("BE SURE THAT ");
  for (int i = 1; i < argc; i++){
    if (i == argc - 1 )
      printf(" and ");
    printf("sd%s", argv[i]);
    if ( i != argc - 1 )
      printf(",");
  } 
  printf(" ARE YOUR TARGETS!!\n\n\n");
  system("lsblk -o name,serial");
  printf("\n\nPress Ctrl+C to exit\n");
  printf("Press Enter to continue");
  while( getchar() != '\n' );

  for (int i = 1; i < 4; i++){
    printf("EXECUTING: sudo dd if=%s of=/dev/sd%s\n", IMG, argv[i]);
    sprintf(command, "sudo dd if=%s of=/dev/sd%s", IMG, argv[i]);
    system(command);
  }
  
  if (argc == 4){
	printf("\n\n%s has a xxhsum of %s\n\n", IMG, XXHSUM);
    printf("EXECUTING: xxhsum /dev/sd%s\n", argv[3]);
    sprintf(command, "xxhsum /dev/sd%s\n", argv[3]);
    system(command);
    return 0;
  }

  for (int i = 4; i < argc;){
    printf("EXECUTING: sudo dd if=/dev/sd%s of=/dev/sd%s\n", argv[1], argv[i]);
    sprintf(command, "sudo dd if=/dev/sd%s of=/dev/sd%s\n", argv[1], argv[i]);
    system(command);
    i++;
    if ( i >= argc )
      break;
    printf("EXECUTING: sudo dd if=/dev/sd%s of=/dev/sd%s\n", argv[2], argv[i]);
    sprintf(command, "sudo dd if=/dev/sd%s of=/dev/sd%s\n", argv[2], argv[i]);
    system(command);
    i++;
    if ( i >= argc )
      break;
    printf("EXECUTING: sudo dd if=/dev/sd%s of=/dev/sd%s\n", argv[3], argv[i]);
    sprintf(command, "sudo dd if=/dev/sd%s of=/dev/sd%s\n", argv[3], argv[i]);
    i++;
  }

	printf("\n\n%s has a xxhsum of %s\n\n\n", IMG, XXHSUM);

  for (int i = argc - 3; i < argc; i++){
    printf("EXECUTING: xxhsum /dev/sd%s\n", argv[i]);
    sprintf(command, "xxhsum /dev/sd%s\n", argv[i]);
    system(command);
  }
  
  return 0;
}
