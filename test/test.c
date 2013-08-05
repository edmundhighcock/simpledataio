#include "stdio.h"
#include "simpledataio.h"

int main (int argc, char * argv){
	sdataio_parallel = 0;
	struct sdatio_file sdatfile;
	sdatio_createfile(&sdatfile, "testfile.cdf");
	printf("Success!\n");
	return 0;
}
