module simpledataio

use netcdf 
use iso_c_binding

integer, parameter :: SDATIO_INT= 0
integer, parameter :: SDATIO_FLOAT= 1
integer, parameter :: SDATIO_DOUBLE= 2
integer, parameter :: SDATIO_COMPLEX_DOUBLE= 3

integer, parameter :: SDATIO_UNLIMITED = NF90_UNLIMITED


type,bind(c) :: sdatio_dimension 
  type(c_ptr) :: name
	integer(c_int) :: size
	integer(c_int) :: nc_id
	integer(c_int) :: start
end type


type :: sdatio_variable 
	character, dimension(:), allocatable :: name
	integer :: nc_id
	integer :: type
  type(c_ptr) :: dimension_list
  type(c_ptr) :: dimension_ids
	integer :: type_size
end type


type, bind(c) :: sdatio_file 
	integer(c_int) :: nc_file_id
	integer(c_int):: is_parallel
	integer(c_int) :: n_dimensions
  type(c_ptr) ::  dimensions
	integer(c_int)  :: n_variables
  type(c_ptr) :: variables
	integer(c_int) :: data_written
end type

!interface 
!!/* Open a new datafile for writing. fname is the name of the file 
 !!* The stuct sfile is used to store the state information
 !!* of the file.*/
!!/* Create a new dimension in the file sfile. Dimension names must
 !!* be a single letter. */
 !subroutine sdatio_add_dimension(sfile, dimension_name, dimsize, description, units)
   !import sdatio_file
   !type(sdatio_file), intent(in) :: sfile
   !character(*), intent(in) :: dimension_name
   !integer, intent(in) :: dimsize
   !character(*), intent(in) :: description, units
 !end subroutine sdatio_add_dimension


!end interface



!int sdatio_debug

!/* Open a new datafile for writing. fname is the name of the file 
 !* The stuct sfile is used to store the state information
 !* of the file.*/
contains 
  subroutine createfile(sfile, fname)
     type(sdatio_file), intent(out) :: sfile
     character(*), intent(in) :: fname
     interface
       subroutine sdatio_createfile(sfile, fname) bind(c, name='sdatio_createfile')
         use iso_c_binding
         import sdatio_file
         type(sdatio_file) :: sfile
         character(c_char) :: fname(*)
       end subroutine sdatio_createfile
     end interface
     call sdatio_createfile(sfile, fname//c_null_char)
   end subroutine createfile

!/* Create a new dimension in the file sfile. Dimension names must
 !* be a single letter. */
 subroutine add_dimension(sfile, dimension_name, dimsize, description, units)
   type(sdatio_file), intent(in) :: sfile
   character(*), intent(in) :: dimension_name
   integer, intent(in) :: dimsize
   character(*), intent(in) :: description, units
   interface
       subroutine sdatio_add_dimension(sfile, dimension_name, dimsize, description, units) bind(c, name='sdatio_add_dimension')
         use iso_c_binding
         import sdatio_file
         type(sdatio_file) :: sfile
         character(c_char) :: dimension_name(*)
         integer(c_int), value :: dimsize
         character(c_char) :: units(*)
         character(c_char) :: description(*)
       end subroutine sdatio_add_dimension
   end interface 
   call sdatio_add_dimension(sfile, dimension_name//c_null_char, dimsize, description//c_null_char, units//c_null_char)
 end subroutine add_dimension
													 !char * dimension_name, 
													 !int size,
													 !char * description,
													 !char * units)


!/* Print out a nice list of all the dimensions defined so far*/
!void sdatio_print_dimensions(struct sdatio_file * sfile)
  subroutine print_dimensions(sfile)
   type(sdatio_file), intent(in) :: sfile
   interface
     subroutine sdatio_print_dimensions(sfile) bind(c, name='sdatio_print_dimensions')
       use iso_c_binding
       import sdatio_file
       type(sdatio_file) :: sfile
     end subroutine sdatio_print_dimensions
   end interface
   call sdatio_print_dimensions(sfile)
  end subroutine print_dimensions



!/* Close the file and free all memory associated with sfile*/
!void sdatio_close(struct sdatio_file * sfile)
  subroutine closefile(sfile)
   type(sdatio_file), intent(in) :: sfile
   interface
     subroutine sdatio_close(sfile) bind(c, name='sdatio_close')
       use iso_c_binding
       import sdatio_file
       type(sdatio_file) :: sfile
     end subroutine sdatio_close
   end interface
   call sdatio_close(sfile)
  end subroutine closefile

!/* Ensure all variables are written to disk in case of crashes*/
!void sdatio_sync(struct sdatio_file * sfile)

!/* Define a variable in the given file. Dimension list 
 !* is a character string listing (in order) the dimension names
 !* (which are all single characters) e.g. "xyx".*/
!void sdatio_create_variable(struct sdatio_file * sfile,
														!int variable_type,
														!char * variable_name,
														!char * dimension_list,
														!char * description,
														!char * units)
 subroutine create_variable(sfile, variable_type, variable_name, dimension_list, description, units)
   type(sdatio_file), intent(in) :: sfile
   integer, intent(in) :: variable_type
   character(*), intent(in) :: variable_name
   character(*), intent(in) :: dimension_list
   character(*), intent(in) :: description, units
   interface
       subroutine sdatio_create_variable(sfile, variable_type, variable_name, dimension_list, description, units) &
            bind(c, name='sdatio_create_variable')
         use iso_c_binding
         import sdatio_file
         type(sdatio_file) :: sfile
         integer(c_int), value :: variable_type
         character(c_char) :: variable_name(*)
         character(c_char) :: dimension_list(*)
         character(c_char) :: units(*)
         character(c_char) :: description(*)
       end subroutine sdatio_create_variable
   end interface 
   call sdatio_create_variable(sfile, variable_type,&
     variable_name//c_null_char, dimension_list//c_null_char, description//c_null_char, units//c_null_char)
 end subroutine create_variable

!/* Write to the given variable. address should be the address of the start of the array */
!void sdatio_write_variable(struct sdatio_file * sfile, char * variable_name, void * address)

!/* Write to the given variable. address should be the address of the start of the array. Indexes should be an array the same size as the number of dimensions of the variable. Using the second form is quicker as the first form requires a search for the variable at every write*/
!void sdatio_write_variable_at_index(struct sdatio_file * sfile, char * variable_name, int * indexes, void * address)
!void sdatio_write_variable_at_index_fast(struct sdatio_file * sfile, struct sdatio_variable * svar, int * indexes, void * address)

!/* Return a pointer the struct containing all the metadata of the given variable */
!struct sdatio_variable * sdatio_find_variable(struct sdatio_file * sfile, char * variable_name)
!/* Return a pointer the struct containing all the metadata of the given dimension */
!struct sdatio_dimension * sdatio_find_dimension(struct sdatio_file * sfile, char * dimension_name)

!/* Print out a nice list of all the variables defined so far*/
!void sdatio_print_variables(struct sdatio_file * sfile)

!/* Increment the start of the specified infinite dimension */
!void sdatio_increment_start(struct sdatio_file * sfile, char * dimension_name)

end module simpledataio
