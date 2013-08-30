// A really dumb, easy to timing-attack, setuid program that prints
// the first few BUFSIZE bytes of a file.  Has the nice property of
// waiting 5 seconds between the critical operations.

#include <stdio.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>

#define BUFSIZE 256

int main(int args, void * argv[])
{
	int fd, res;
	int count = 0;
	char *file1, *file2;
	int ret = -1;

	if(args < 4){
		printf("use: %s file1 file2 count\n", (const char *) argv[0]);
		return 0;
	}

	count = atoi(argv[3]);
	file1 = argv[1];
	file2 = argv[2];

	while(count >= 0){

		if(count % 2){
			ret = link(file1, file2);
			assert(ret == 0);
			ret = unlink(file1);
			assert(ret == 0);
		} else {
			ret = link(file2, file1);
			assert(ret == 0);
			ret = unlink(file2);
			assert(ret == 0);
		}

		count--;
	}

	return 0;
}
