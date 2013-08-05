#include "simpledataio.h"

#define ERRCODE 2
#define ERR(e) {printf("Error: %s\n", nc_strerror(e)); exit(ERRCODE);}
#define DEBUG_MESS if (sdatio_debug) printf


/* Private*/
void sdatio_end_definitions(struct sdatio_file * sfile){
	int retval;
	if ((retval = nc_enddef(sfile->nc_file_id))) ERR(retval);
}

/* Private */
void sdatio_recommence_definitions(struct sdatio_file * sfile){
	int retval;
	if ((retval = nc_redef(sfile->nc_file_id))) ERR(retval);
}

void sdatio_createfile(struct sdatio_file * sfile, char * fname)  {
	printf("called\n");
	int retval;
	/*if (0){}*/
	/*else {*/
		if ((retval = nc_create(fname, NC_NOCLOBBER, &(sfile->nc_file_id)))) ERR(retval);
		/*}*/
	sfile->n_dimensions = 0;
	sfile->is_parallel = 0;
	sdatio_end_definitions(sfile);
}

/* Private */
void sdatio_append_dimension(struct sdatio_file * sfile, struct sdatio_dimension * sdim){
	int ndims;
	struct sdatio_dimension ** new_dimensions; 
	int i;
	ndims = sfile->n_dimensions + 1;
		

	new_dimensions = (struct sdatio_dimension **) malloc(sizeof(struct sdatio_dimension *)*ndims);

	DEBUG_MESS("Setting dimensions; %d, %d\n", ndims, sfile->n_dimensions);

	for (i=0; i < ndims-1; i++){
		DEBUG_MESS("i %d\n", i);
		new_dimensions[i] = sfile->dimensions[i];
	}

	DEBUG_MESS("Setting new\n");

	new_dimensions[ndims-1] = sdim;

	DEBUG_MESS("About to deallocate old dimensions\n");

	if (sfile->n_dimensions > 0) free(sfile->dimensions);
	sfile->n_dimensions = ndims;

	sfile->dimensions = new_dimensions;
	
}

void sdatio_add_dimension(struct sdatio_file * sfile, 
													 char * dimension_name, 
													 int size,
													 char * description,
													 char * units){

	struct sdatio_dimension  * sdim;
	int retval;
	sdim = (struct sdatio_dimension *) malloc(sizeof(struct sdatio_dimension));
	sdatio_recommence_definitions(sfile);
	if (sfile->is_parallel){}
	else {
		if ((retval = nc_def_dim(sfile->nc_file_id, dimension_name, size, &(sdim->nc_id)))) ERR(retval);
	}
	sdatio_end_definitions(sfile);
	sdim->size = size;
	if (strlen(dimension_name)>1){
		printf("Dimension names can only be one character long!\n");
		abort();
	}
	sdim->name = (char *)malloc(sizeof(char)*2);
	strcpy(sdim->name, dimension_name);
	sdatio_append_dimension(sfile, sdim);

}

void sdatio_print_dimensions(struct sdatio_file * sfile){
	int i;
	struct sdatio_dimension * sdim;
	for (i=0;i<sfile->n_dimensions;i++){
		sdim = sfile->dimensions[i];
		printf("Dimension %s, size %d\n", sdim->name, sdim->size);
		
	}
}

/* Private*/
void sdatio_free_dimension(struct sdatio_dimension * sdim){
	free(sdim->name);
	free(sdim);
}

void sdatio_free(struct sdatio_file * sfile){
	int i;
	for (i=0;i<sfile->n_dimensions;i++){
		sdatio_free_dimension(sfile->dimensions[i]);
	}
	free(sfile->dimensions);

}

