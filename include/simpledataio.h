#include "stdio.h"
#include <stdlib.h>
#include <netcdf.h>

struct sdatio_dimension {
	char * name;
	int size;
	int nc_id;
};


struct sdatio_file {
	int nc_file_id;
	int n_dimensions;
	int is_parallel;
	struct sdatio_dimension ** dimensions;
};


int sdatio_debug;

/* Open a new datafile for writing. fname is the name of the file 
 * The stuct sfile is used to store the state information
 * of the file.*/
void sdatio_createfile(struct sdatio_file * sfile, char * fname);

/* Create a new dimension in the file sfile. Dimension names must
 * be a single letter. */
void sdatio_add_dimension(struct sdatio_file * sfile, 
													 char * dimension_name, 
													 int size,
													 char * description,
													 char * units);

/* Print out a nice list of all the dimensions defined so far*/
void sdatio_print_dimensions(struct sdatio_file * sfile);


/* Free all memory associated with sfile*/
void sdatio_free(struct sdatio_file * sfile);
