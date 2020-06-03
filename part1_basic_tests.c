#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include <stdlib.h>
#include <assert.h>

#define DATA_CHUNK_SIZE 8

bool isCorrect(uint8_t data);
int find_index_of_errored_row(uint8_t* data, int* err_row_index);
int fix_data_block(uint8_t* data);

int main() {
	uint8_t data[DATA_CHUNK_SIZE] = {
            0b10010011,
            0b01000001,
			0b11010001,
			0b11000011,
			0b11101101,
			0b11001010,
			0b01000001,
            0b10100110
    };
	
	uint8_t bad_data[DATA_CHUNK_SIZE] = {
            0b10010011,
            0b01000001,
			0b11000001,
			0b11000011,
			0b11101101,
			0b11001010,
			0b01000001,
            0b10100110
    };
	
	uint8_t very_bad_data[DATA_CHUNK_SIZE] = {
            0b10010011,
            0b01000001,
			0b11000001,
			0b11000011,
			0b11101001,
			0b11001010,
			0b01000001,
            0b10100110
    };
	
	printf("Oh, the text we got was broken. It is: ");
	for(int i=0; i<DATA_CHUNK_SIZE-1; i++) {
		printf("%c", bad_data[i] >> 1);
	}
	printf("\n");
	
	bool res = isCorrect(data[0]);
	assert(res);
	res = isCorrect(bad_data[2]);
	assert(!res);
	int err_row_index;
	// printf("success?");
	// find_index_of_errored_row(data, &err_row_index);
	// printf("%d", err_row_index);
	assert(find_index_of_errored_row(data, &err_row_index)==0 && err_row_index==-1);
	assert(find_index_of_errored_row(bad_data, &err_row_index)==1 && err_row_index==2);
	
	assert(fix_data_block(bad_data)==2);
	for(int i=0; i<DATA_CHUNK_SIZE; i++) {
        assert(bad_data[i] == data[i]);
    }
	
	assert(fix_data_block(bad_data)==1);
	for(int i=0; i<DATA_CHUNK_SIZE; i++) {
        assert(bad_data[i] == data[i]);
    }
	
	assert(fix_data_block(very_bad_data)==0);
	
	printf("Yay! you fixed the text. Now it is: ");
	for(int i=0; i<DATA_CHUNK_SIZE-1; i++) {
		printf("%c", bad_data[i] >> 1);
	}
	printf("\n");
	
	return 0;
}