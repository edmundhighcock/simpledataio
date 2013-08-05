#include "simpledataio.h"

#define ERRCODE 2
#define ERR(e) {printf("Error: %s\n", nc_strerror(e)); exit(ERRCODE);}


void sdatio_createfile(struct sdatio_file * sfile, char * fname)  {
	printf("called\n");
	int retval;
	if (sdataio_parallel){}
	else {
		if ((retval = nc_create(fname, NC_NOCLOBBER, &(sfile->nc_file_id)))) ERR(retval);
	}
	sfile->n_dimensions = 0;
}


