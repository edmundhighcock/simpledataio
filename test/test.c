#include "stdio.h"
#include "simpledataio.h"

int main (int argc, char * argv){
	struct sdatio_file sdatfile;
	double yvar[2] = {0.1,0.3};
	int iy[2] = {1,2};
	double phivar[3][2] = {{0.1,0.3}, {2.0, 4.0}, {-1.0, 3.6}};
	double t;
	double phi_tvar[2];

	sdatio_debug = 1;

	sdatio_createfile(&sdatfile, "testfile.cdf");

	sdatio_add_dimension(&sdatfile, "x", 3, "The x coordinate", "m");
	sdatio_add_dimension(&sdatfile, "y", 2, "The y coordinate", "m");
	sdatio_add_dimension(&sdatfile, "t", SDATIO_UNLIMITED, "The time coordinate", "s");
	sdatio_print_dimensions(&sdatfile);

	sdatio_create_variable(&sdatfile, SDATIO_DOUBLE, "phi", "xy", "Some potential", "Vm");
	sdatio_create_variable(&sdatfile, SDATIO_DOUBLE, "phi_t", "ty", "Some potential as a function of y and time", "Vm");
	sdatio_create_variable(&sdatfile, SDATIO_DOUBLE, "y", "y", "Values of the y coordinate", "m");
	sdatio_create_variable(&sdatfile, SDATIO_DOUBLE, "t", "t", "Values of the time coordinate", "m");
	sdatio_create_variable(&sdatfile, SDATIO_INT, "iky", "y", "y index values", "(none)");


	sdatio_write_variable(&sdatfile, "y", &yvar[0]);
	sdatio_write_variable(&sdatfile, "iky", &iy[0]);
	sdatio_write_variable(&sdatfile, "phi", &phivar[0]);

	t = 0.3;
	phi_tvar[0] = 4;
	phi_tvar[1] = 6;
	sdatio_write_variable(&sdatfile, "t", &t);
	sdatio_write_variable(&sdatfile, "phi_t", &phi_tvar);

	sdatio_increment_start(&sdatfile, "t");
	sdatio_write_variable(&sdatfile, "t", &t);
	sdatio_write_variable(&sdatfile, "phi_t", &phi_tvar);


	t = 0.4;
	
	phi_tvar[0] = 4.8;
	phi_tvar[1] = 6.9;
	sdatio_increment_start(&sdatfile, "t");
	sdatio_write_variable(&sdatfile, "t", &t);
	sdatio_write_variable(&sdatfile, "phi_t", &phi_tvar);

	sdatio_print_variables(&sdatfile);

	sdatio_close(&sdatfile);

	printf("Success!\n");
	return 0;
}
