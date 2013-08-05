#include "simpledataio.h"
#include "string.h"

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
	sfile->n_variables = 0;
	sfile->is_parallel = 0;
	sdatio_end_definitions(sfile);
}



/***********************************************************
 *
 * Handling Dimensions
 *
 **********************************************************/


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
	sdim->start = 0;
	sdatio_append_dimension(sfile, sdim);

}

void sdatio_print_dimensions(struct sdatio_file * sfile){
	int i;
	struct sdatio_dimension * sdim;
	for (i=0;i<sfile->n_dimensions;i++){
		sdim = sfile->dimensions[i];
		printf("Dimension %s, size %d, has id %d\n", sdim->name, sdim->size, sdim->nc_id);
	}
}

void sdatio_increment_start(struct sdatio_file * sfile, char * dimension_name){

	int found, j;
	struct sdatio_dimension * sdim;

	found = 0;
	for (j=0;j<sfile->n_dimensions;j++){
		sdim = sfile->dimensions[j];
		if (!strcmp(sdim->name, dimension_name)){
			if (sdim->size != SDATIO_UNLIMITED) {
				printf("Dimension %s does not have unlimited size.\n", dimension_name);
				abort();
			}		
			found = 1;
			(sdim->start)++;
		}
	}
	if (!found) {
		printf("Couldn't find dimension %s in sdatio_increment_count\n", dimension_name);
		abort();
	}
}

/* Private*/
void sdatio_free_dimension(struct sdatio_dimension * sdim){
	free(sdim->name);
	free(sdim);
}



/***************************************************
 *
 * Handling Variables
 *
 * ***********************************************/

int sdatio_netcdf_variable_type(int type){
	switch (type){
		case SDATIO_INT:
			return NC_INT;
		case SDATIO_DOUBLE:
			return NC_DOUBLE;
		case SDATIO_COMPLEX_DOUBLE:
			printf("Can't do complex yet\n");
			abort();
		default:
			printf("Unknown data type for simple data io\n");
			abort();
	}
}

void sdatio_get_dimension_ids(struct sdatio_file * sfile, char * dimension_list, struct sdatio_variable * svar){
	int ndims;
	int i,j;
	char dim_name[2];
	int * dimension_ids;
	ndims  = strlen(dimension_list);
	DEBUG_MESS("ndims %d\n", ndims);
	dimension_ids = (int *) malloc(sizeof(int)*ndims);
	for (i=0;i<ndims;i++){
		dim_name[0] = dimension_list[i];
		dim_name[1] = dimension_list[ndims];
		DEBUG_MESS("i %d\n", i);
		DEBUG_MESS("Getting id for dim %s\n", dim_name);
		dimension_ids[i] = -1;
		for (j=0;j<sfile->n_dimensions;j++){
			DEBUG_MESS("j %d\n", j);
			if (!strcmp(dim_name, sfile->dimensions[j]->name)) 
				dimension_ids[i] = sfile->dimensions[j]->nc_id;
		}
		if (dimension_ids[i]==-1){
			printf("Dimension %s is undefined!\n", dim_name);
			abort();
		}
		DEBUG_MESS("Finished loop\n");
		DEBUG_MESS("dim %s has id %d \n", dim_name, dimension_ids[i]);
	}
	svar->dimension_ids = dimension_ids;


}
/*Private*/
void sdatio_append_variable(struct sdatio_file * sfile, struct sdatio_variable * svar){
	int nvars;
	struct sdatio_variable ** new_variables; 
	int i;
	nvars = sfile->n_variables + 1;
		

	new_variables = (struct sdatio_variable **) malloc(sizeof(struct sdatio_variable *)*nvars);

	DEBUG_MESS("Setting variable %s; %d, %d\n", svar->name, nvars, sfile->n_variables);

	for (i=0; i < nvars-1; i++){
		DEBUG_MESS("i %d\n", i);
		new_variables[i] = sfile->variables[i];
	}

	DEBUG_MESS("Setting new\n");

	new_variables[nvars-1] = svar;

	DEBUG_MESS("About to deallocate old variables\n");

	if (sfile->n_variables > 0) free(sfile->variables);

	sfile->n_variables = nvars;

	sfile->variables = new_variables;

	DEBUG_MESS("Deallocated old vars\n");
	
}

void sdatio_create_variable(struct sdatio_file * sfile,
														int variable_type,
														char * variable_name,
														char * dimension_list,
														char * description,
														char * units){
	int ndims;
	struct sdatio_variable  * svar;
	int retval;
	/*int * dimension_ids;*/

	/*dimension_ids = (int **)malloc(sizeof(int*));*/


	svar = (struct sdatio_variable *) malloc(sizeof(struct sdatio_variable));
	sdatio_get_dimension_ids(sfile, dimension_list, svar);
	/*svar->dimension_ids = dimension_ids;*/

	ndims = strlen(dimension_list);

	sdatio_recommence_definitions(sfile);
	if (sfile->is_parallel){}
	else {
		if ((retval = nc_def_var(sfile->nc_file_id, variable_name, sdatio_netcdf_variable_type(variable_type), ndims, svar->dimension_ids, &(svar->nc_id)))) ERR(retval);
		if ((retval = nc_put_att_text(sfile->nc_file_id, svar->nc_id, "Description", strlen(description), description))) ERR(retval);
		if ((retval = nc_put_att_text(sfile->nc_file_id, svar->nc_id, "Units", strlen(units), units))) ERR(retval);
	}
	sdatio_end_definitions(sfile);
	
	svar->type = variable_type;
	svar->name = (char *)malloc(sizeof(char)*(strlen(variable_name)+1));
	strcpy(svar->name, variable_name);
	svar->dimension_list = (char *)malloc(sizeof(char)*(ndims+1));
	strcpy(svar->dimension_list, dimension_list);
	sdatio_append_variable(sfile, svar);
	
}

void sdatio_print_variables(struct sdatio_file * sfile){
	int i;
	struct sdatio_variable * svar;
	for (i=0;i<sfile->n_variables;i++){
		svar = sfile->variables[i];
		printf("Variable %s, dimensions %s, has id %d\n", svar->name, svar->dimension_list, svar->nc_id);
	}
}

/* Private */
void sdatio_get_counts_and_starts(struct sdatio_file * sfile, struct sdatio_variable * svar, size_t * counts, size_t * starts){
	struct sdatio_dimension * sdim;
	int i,j;
	int found;
	for (i=0;i<strlen(svar->dimension_list);i++){
		found = 0;
		for (j=0;j<sfile->n_dimensions;j++){
			sdim = sfile->dimensions[j];
			if (sdim->nc_id == svar->dimension_ids[i]){
				starts[i] = sdim->start;
				found = 1;
				if (sdim->size == SDATIO_UNLIMITED) counts[i] = 1; 
				else counts[i] = sdim->size;
			}
		}
		if (!found) {
			printf("Couldn't find dimension in sdatio_get_counts_and_starts\n");
			abort();
		}
	}
}

void sdatio_write_variable(struct sdatio_file * sfile, char * variable_name, void * address){
	int i, variable_number, retval, ndims;
	struct sdatio_variable * svar;
	double * double_array;
	size_t * counts, * starts;

	variable_number = -1;

	DEBUG_MESS("Finding variable...\n");

	for (i=0;i<sfile->n_variables;i++)
		if (!strcmp(sfile->variables[i]->name, variable_name))
			variable_number = i;

	if (variable_number==-1){
		printf("Couldn't find variable %s\n", variable_name);
		abort();
	}
	svar = sfile->variables[variable_number];
	

	ndims = strlen(svar->dimension_list);
	counts = (size_t*)malloc(sizeof(size_t)*ndims); 
	starts = (size_t*)malloc(sizeof(size_t)*ndims); 

	sdatio_get_counts_and_starts(sfile, svar, counts, starts);

	if (sfile->is_parallel){}
	else {
		switch (svar->type){
			case (SDATIO_INT):
				DEBUG_MESS("Writing an integer\n");
				if ((retval = nc_put_var_int(sfile->nc_file_id, svar->nc_id, address))) ERR(retval);
				break;
			case (SDATIO_DOUBLE):
				DEBUG_MESS("Writing a double\n");
				/*if ((retval = nc_put_var_double(sfile->nc_file_id, svar->nc_id, address))) ERR(retval);*/
				if ((retval = nc_put_vara_double(sfile->nc_file_id, svar->nc_id, starts, counts, address))) ERR(retval);
				break;
		}
		
	}
}

/* Private*/
void sdatio_free_variable(struct sdatio_variable * svar){
	free(svar->name);
	free(svar->dimension_list);
	free(svar->dimension_ids);
	free(svar);
}

void sdatio_close(struct sdatio_file * sfile){
	int i, retval;

	if (sfile->is_parallel){}
	else {

		if ((retval = nc_close(sfile->nc_file_id))) ERR(retval);
	}

	for (i=0;i<sfile->n_dimensions;i++){
		sdatio_free_dimension(sfile->dimensions[i]);
	}
	free(sfile->dimensions);
	for (i=0;i<sfile->n_variables;i++){
		sdatio_free_variable(sfile->variables[i]);
	}
	free(sfile->variables);

}
