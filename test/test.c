#include "stdio.h"
#include "simpledataio.h"

int main (int argc, char * argv){
	struct sdatio_file sdatfile;

	sdatio_debug = 1;

	sdatio_createfile(&sdatfile, "testfile.cdf");

	sdatio_add_dimension(&sdatfile, "x", 5, "The x coordinate", "m");
	sdatio_add_dimension(&sdatfile, "y", 2, "The y coordinate", "m");

	sdatio_print_dimensions(&sdatfile);

	sdatio_free(&sdatfile);

	printf("Success!\n");
	return 0;
}
