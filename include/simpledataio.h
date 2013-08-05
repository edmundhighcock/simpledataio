#include "stdio.h"
#include <stdlib.h>
#include <netcdf.h>

struct sdatio_dimension {
	char * name;
	int size;
};

struct sdatio_file {
	int nc_file_id;
	int n_dimensions;
	struct sdatio_dimension * dimensions;
};


int sdataio_parallel;

/* Open a new datafile for writing. fname is the name of the file 
 * The stuct sfile is used to store the state information
 * of the file.*/
void sdatio_createfile(struct sdatio_file * sfile, char * fname);
