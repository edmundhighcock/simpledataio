!module get_c_address
  !use iso_c_binding
  !interface c_address
    !module procedure c_address_real
  !end interface c_address

!contains
  !function c_address_real(variable)
    !real, intent(in) :: variable
    !real(c_float), allocatable, target :: var
    !type(c_ptr) ::  c_address_real
    !allocate(var)
    !var = variable
    !c_address_real = c_loc(var)
    !write (*,*) 'var', var, variable, c_address_real
   !end function c_address_real
!end module get_c_address

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
  subroutine syncfile(sfile)
   type(sdatio_file), intent(in) :: sfile
   interface
     subroutine sdatio_sync(sfile) bind(c, name='sdatio_sync')
       use iso_c_binding
       import sdatio_file
       type(sdatio_file) :: sfile
     end subroutine sdatio_sync
   end interface
   call sdatio_sync(sfile)
  end subroutine syncfile

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
   implicit none
   type(sdatio_file), intent(in) :: sfile
   integer, intent(in) :: variable_type
   character(*), intent(in) :: variable_name
   character(*), intent(in) :: dimension_list
   character(*), intent(in) :: description, units
   !character, dimension(:), allocatable :: dimension_list_reversed
   character(len(dimension_list)) :: dimension_list_reversed
   integer :: i
   interface
       subroutine sdatio_create_variable(sfile, variable_type, variable_name, dimension_list, description, units) &
            bind(c, name='sdatio_create_variable')
         use iso_c_binding
         import sdatio_file
         type(sdatio_file) :: sfile
         integer(c_int), value :: variable_type
         character(c_char) :: variable_name(*)
         character(c_char) :: dimension_list
         character(c_char) :: units(*)
         character(c_char) :: description(*)
       end subroutine sdatio_create_variable
   end interface 
   !allocate(dimension_list_reversed(len(dimension_list)))
   !if (len(dimension_list) .gt. 0) then
     do i = 1,len(dimension_list)
       dimension_list_reversed(i:i) = dimension_list(len(dimension_list)-i+1:len(dimension_list)-i+1)
     end do
   write (*,*) 'dimension_list ', dimension_list, ' dimension_list_reversed ', dimension_list_reversed
   call sdatio_create_variable(sfile, variable_type,&
     variable_name//c_null_char, dimension_list_reversed//c_null_char, description//c_null_char, units//c_null_char)
   !else 
   !call sdatio_create_variable(sfile, variable_type,&
     !variable_name//c_null_char, dimension_list//c_null_char, description//c_null_char, units//c_null_char)
   !end if
 end subroutine create_variable


!/* Write to the given variable. address should be the address of the start of the array */
!void sdatio_write_variable(struct sdatio_file * sfile, char * variable_name, void * address)
 !subroutine write_variable(sfile,variable_name, address)
   !type(sdatio_file), intent(in) :: sfile
   !character(*), intent(in) :: variable_name
   !type(c_ptr) :: address
   !interface
       !subroutine sdatio_write_variable_fortran_convert(sfile, variable_name, address) &
            !bind(c, name='sdatio_write_variable_fortran_convert' )
         !use iso_c_binding
         !import sdatio_file
         !type(sdatio_file) :: sfile
         !character(c_char) :: variable_name(*)
         !type(c_ptr) :: address
       !end subroutine sdatio_write_variable_fortran_convert
   !end interface 
   !write (*,*) 'address is ', address
   !call sdatio_write_variable_fortran_convert(sfile, variable_name//c_null_char, address)
 !end subroutine write_variable


 subroutine write_variable_real_1(sfile, variable_name, val)
   use netcdf
   type(sdatio_file), intent(in) :: sfile
   character(*), intent(in) :: variable_name
   real, intent(in) :: val
   integer, dimension(:), allocatable :: starts, counts
   integer :: fileid, varid, status, n

   call number_of_unlimited_dimensions(sfile, variable_name, n)
   allocate(starts(n))
   allocate(counts(n))
   !write (*,*) 'counts', size(counts), 'starts', size(starts)
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts)
   status =  nf90_put_var(fileid, varid+1, (/val/), start=starts, count=counts)
   !status =  nf90_put_var(fileid, varid+1, val)
   if (.not. status .eq. 0) write (*,*) 'Error writing variable: ', variable_name, ', ',  nf90_strerror(status)
   !call nf90_put_var(fileid, varid, val)


 end subroutine write_variable_real_1

!/* Write to the given variable. address should be the address of the start of the array. Indexes should be an array the same size as the number of dimensions of the variable. Using the second form is quicker as the first form requires a search for the variable at every write*/
!void sdatio_write_variable_at_index(struct sdatio_file * sfile, char * variable_name, int * indexes, void * address)
!void sdatio_write_variable_at_index_fast(struct sdatio_file * sfile, struct sdatio_variable * svar, int * indexes, void * address)

!/* Return a pointer the struct containing all the metadata of the given variable */
!struct sdatio_variable * sdatio_find_variable(struct sdatio_file * sfile, char * variable_name)
!/* Return a pointer the struct containing all the metadata of the given dimension */
!struct sdatio_dimension * sdatio_find_dimension(struct sdatio_file * sfile, char * dimension_name)
 !function find_variable(sfile,variable_name)
   !type(sdatio_file), intent(in) :: sfile
   !character(*), intent(in) :: variable_name
   !type(sdatio_variable), pointer :: find_variable
   !interface
     !type(c_ptr) function sdatio_find_variable(sfile, variable_name) &
            !bind(c, name='sdatio_find_variable' )
         !use iso_c_binding
         !import sdatio_file
         !import sdatio_variable
         !type(sdatio_file) :: sfile
         !character(c_char) :: variable_name(*)
         !!type(sdatio_variable) :: sdatio_find_variable
       !end function sdatio_find_variable
   !end interface 
   !write (*,*) 'calling'
   !call c_f_pointer(sdatio_find_variable(sfile, variable_name//c_null_char), find_variable)
 !end function find_variable

 subroutine number_of_unlimited_dimensions(sfile, variable_name, n)
   type(sdatio_file), intent(in) :: sfile
   character(*), intent(in) :: variable_name
   integer, intent(out) :: n
   interface
       subroutine sdatio_number_of_unlimited_dimensions(sfile, variable_name, n) &
            bind(c, name='sdatio_number_of_unlimited_dimensions')
         use iso_c_binding
         import sdatio_file
         type(sdatio_file) :: sfile
         integer(c_int) :: n
         character(c_char) :: variable_name(*)
       end subroutine sdatio_number_of_unlimited_dimensions
   end interface 
   call sdatio_number_of_unlimited_dimensions(sfile, variable_name//c_null_char, n)
 end subroutine number_of_unlimited_dimensions

 subroutine netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts)
   type(sdatio_file), intent(in) :: sfile
   character(*), intent(in) :: variable_name
   integer, intent(out) :: fileid, varid
   integer, intent(out), dimension(:) :: starts, counts
   integer(c_size_t), dimension(:), allocatable, target :: starts_c, counts_c
   type(c_ptr) :: starts_ptr, counts_ptr
   integer :: i,n
   interface
       subroutine sdatio_netcdf_inputs(sfile, variable_name, fileid, varid, starts_ptr, counts_ptr) &
            bind(c, name='sdatio_netcdf_inputs')
         use iso_c_binding
         import sdatio_file
         type(sdatio_file) :: sfile
         integer(c_int) :: varid, fileid
         character(c_char) :: variable_name(*)
         type(c_ptr), value :: starts_ptr, counts_ptr
       end subroutine sdatio_netcdf_inputs
   end interface 
   allocate(starts_c(size(starts)))
   allocate(counts_c(size(counts)))

   call sdatio_netcdf_inputs(sfile, variable_name//c_null_char, fileid, varid,  c_loc(starts_c), c_loc(counts_c))

   n = size(starts)
   do i = 1,n
     counts(i) = counts_c(n-i+1)
     !counts(i) = counts_c(i)
     starts(i) = starts_c(n-i+1)+1
     !starts(i) = starts_c(i)+1
   end do
   
   write (*,*) 'sc', starts, counts, ' n', n

   deallocate(counts_c, starts_c)

 end subroutine netcdf_inputs



!/* Print out a nice list of all the variables defined so far*/
!void sdatio_print_variables(struct sdatio_file * sfile)
  subroutine print_variables(sfile)
   type(sdatio_file), intent(in) :: sfile
   interface
     subroutine sdatio_print_variables(sfile) bind(c, name='sdatio_print_variables')
       use iso_c_binding
       import sdatio_file
       type(sdatio_file) :: sfile
     end subroutine sdatio_print_variables
   end interface
   call sdatio_print_variables(sfile)
  end subroutine print_variables

!/* Increment the start of the specified infinite dimension */
!void sdatio_increment_start(struct sdatio_file * sfile, char * dimension_name)
  subroutine increment_start(sfile, dimension_name)
   type(sdatio_file), intent(in) :: sfile
   character(*), intent(in) :: dimension_name
   interface
     subroutine sdatio_increment_start(sfile, dimension_name) bind(c, name='sdatio_increment_start')
       use iso_c_binding
       import sdatio_file
       type(sdatio_file) :: sfile
       character(c_char) :: dimension_name
     end subroutine sdatio_increment_start
   end interface
   call sdatio_increment_start(sfile, dimension_name//c_null_char)
  end subroutine increment_start

end module simpledataio
