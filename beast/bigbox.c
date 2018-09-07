#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <string.h>

// To compile: gcc -Wall -o bigbox bigbox.c
// Written by: Connor McMillan

void stop(int signum){
	printf("Exiting...");
	exit(signum);
}

int main(int argc, char *argv[]){
	signal(SIGTERM, stop);
	char command[128];
	char IMG[] = "/dev/sda or /path/to/image.img";

	if ( argc <= 3 ){
		printf("ERROR: Not enough arguments.\n");
		printf("You need to image at least 3 drives.\n");
		printf("%s [target] [target] [target] [target] ...\n", argv[0]);
		printf("Example: %s a b c d e f g h i j k l\n", argv[0]);
		printf("Where IMG=%s\n", IMG);
		return 1;
	}

	printf("Enter master image filename or device.\n");
	printf("Example: /dev/sda or /path/to/image.img\n");
	printf("> ");
	fgets(IMG,256,stdin);
	strtok(IMG, "\n");
	
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
		sprintf(command, "sudo dd if=%s of=/dev/sd%s", IMG, argv[i]);
		printf("EXECUTING: %s\n", command);
		system(command);
	}
  
	if (argc == 4){
		printf("\n\nGenerating %s xxhsum...\n", IMG);
		sprintf(command, "sudo xxhsum %s", IMG);
		printf("EXECUTING: %s\n", command);
		system(command);
		printf("\n\nGenerating /dev/sd%s xxhsum...\n", argv[3]);
		sprintf(command, "sudo xxhsum /dev/sd%s", argv[3]);
		printf("EXECUTING: %s\n", command);
		system(command);
		return 0;
	}

	for (int i = 4; i < argc;){
		sprintf(command, "sudo dd if=/dev/sd%s of=/dev/sd%s", argv[1], argv[i]);
		printf("EXECUTING: %s\n", command);
		system(command);
		i++;
   
		if ( i >= argc )
			break;
		sprintf(command, "sudo dd if=/dev/sd%s of=/dev/sd%s", argv[2], argv[i]);
		printf("EXECUTING: %s\n", command);
		system(command);
		i++;
    
		if ( i >= argc )
			break;
		sprintf(command, "sudo dd if=/dev/sd%s of=/dev/sd%s", argv[3], argv[i]);
		printf("EXECUTING: %s\n", command);
		system(command);
		i++;
	}

	printf("\n\nGenerating %s xxhsum...\n", IMG);
	sprintf(command, "sudo xxhsum %s", IMG);
	printf("EXECUTING: %s\n", command);
	system(command);

	for (int i = argc - 3; i < argc; i++){
		sprintf(command, "sudo xxhsum %s", argv[i]);
		printf("EXECUTING: %s\n", command);
		system(command);
	}
  
	return 0;
}
