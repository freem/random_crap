/*
 * frequency_count
 * Counts the frequency of bytes and nibbles in a file.
 * Also gives a list of unused hex values.
 *
 * by freem, September 2025
 * License: public domain, Unlicense, CC0, whatever
 */

#include <stdio.h>
#include <stdlib.h>

int main(int argc, char **argv){
	FILE *inFile;
	int inputSize;
	int curVal = 0;
	int unusedValueCount = 0;
	int unusedValueSep = 0;
	int frequencyCountTotal[256];
	int frequencyCountUpper[16];
	int frequencyCountLower[16];

	if(argc == 1){
		printf("frequency_count\n");
		printf("Counts the frequency of bytes and nibbles in a file.\n");
		printf("usage: frequency_count binflie\n");
		exit(EXIT_SUCCESS);
	}

	if(argc > 2){
		printf("Error: Too many arguments\n");
		exit(EXIT_FAILURE);
	}

	for(int i = 0; i < 16; i++){
		frequencyCountUpper[i]=0;
		frequencyCountLower[i]=0;
	}
	for(int i = 0; i < 256; i++){
		frequencyCountTotal[i]=0;
	}

	inFile = fopen(argv[1],"rb");
	if(inFile != NULL){
		do{
			curVal = fgetc(inFile);
			if(curVal != EOF){
				frequencyCountTotal[curVal]++;
				frequencyCountUpper[((curVal&0xF0)>>4)]++;
				frequencyCountLower[(curVal&0x0F)]++;
			}
		}while(curVal != EOF);
		inputSize = ftell(inFile);
		fclose(inFile);

		printf("frequency_count Information for '%s'\n",argv[1]);
		printf("Input file size: %d bytes\n\n",inputSize);

		printf("Byte Frequency Count\n");
		printf("--------------------\n");
		for(int i = 0; i < 256; i++){
			printf("$%02X = % 6d (%f%%)\n",i,frequencyCountTotal[i],((float)frequencyCountTotal[i]/inputSize)*100);
			if(frequencyCountTotal[i] == 0){
				++unusedValueCount;
			}
		}
		printf("\n");
		printf("Nibble Frequency Count\n");
		printf("----------------------\n");
		for(int i = 0; i < 16; i++){
			printf("$%X_ = % 6d | $_%X = % 6d\n", i,frequencyCountUpper[i], i,frequencyCountLower[i]);
		}
		printf("\n");
		printf("Unused value count: %d\n",unusedValueCount);
		printf("-------------------------\n");

		for(int i = 0; i < 256; i++){
			if(frequencyCountTotal[i] == 0){
				printf("%02X ",i);
				++unusedValueSep;
			}
			if(unusedValueSep == 16){
				unusedValueSep = 0;
				printf("\n");
			}
		}

		printf("\n");
	}
	else{
		perror("Unable to open file");
		exit(EXIT_FAILURE);
	}

	exit(EXIT_SUCCESS);
}
