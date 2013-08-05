#include "stdio.h"
#include "simpledataio.h"

int main (int argc, char * argv){
	struct sdatio_file sdatfile;
	double yvar[2] = {0.1,0.3};

	sdatio_debug = 1;

	sdatio_createfile(&sdatfile, "testfile.cdf");

	sdatio_add_dimension(&sdatfile, "x", 5, "The x coordinate", "m");
	sdatio_add_dimension(&sdatfile, "y", 2, "The y coordinate", "m");
	sdatio_print_dimensions(&sdatfile);

	sdatio_create_variable(&sdatfile, SDATIO_DOUBLE, "phi", "xy", "Some potential", "Vm");
	sdatio_create_variable(&sdatfile, SDATIO_DOUBLE, "y", "y", "Values of the y coordinate", "m");


	sdatio_write_variable(&sdatfile, "y", &yvar[0]);


	sdatio_print_variables(&sdatfile);

	sdatio_close(&sdatfile);

	printf("Success!\n");
	return 0;
}
