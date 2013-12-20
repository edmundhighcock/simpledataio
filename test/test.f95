program test
  use simpledataio
  use simpledataio_write
  use get_c_address
  implicit none
  type (sdatio_file) :: sdatfile
  type (sdatio_variable), pointer :: svar
  type (sdatio_variable) :: svar2
  real :: parameter1 = 0.5
  double precision, dimension(2) :: yvar = (/0.1d0, 0.3d0/)
	real, dimension(2) :: floatvar = (/0.1,0.3/)
	integer, dimension(2) :: iy = (/1,2/)
	!double precision, dimension(3,2) ::  phivar = (/(/0.1,0.3/), (/2.0, 4.0/), (/-1.0, 3.6/)/);
	double precision, dimension(3,2) ::  phivar = reshape((/0.1d0,2.0d0,-1.0d0, 0.3d0,4.0d0, 3.6d0/), (/3,2/))
  write (*, *) 'phivar', phivar(2,1)

  call createfile(sdatfile, "test.cdf")
	call add_dimension(sdatfile, "x", 3, "The x coordinate", "m")
	call add_dimension(sdatfile, "y", 2, "The y coordinate", "m")
	call add_dimension(sdatfile, "t", SDATIO_UNLIMITED, "The time coordinate", "s")
  call print_dimensions(sdatfile)

	call create_variable(sdatfile, SDATIO_DOUBLE, "phi", "xy", "Some potential", "Vm")
	call create_variable(sdatfile, SDATIO_DOUBLE, "parameter", "", "A scalar parameter", "(none)")
	call create_variable(sdatfile, SDATIO_FLOAT, "floatvar", "y", "A single precision variable.", "Vm")
	call create_variable(sdatfile, SDATIO_DOUBLE, "phi_t", "yt", "Some potential as a function of y and time", "Vm")
	call create_variable(sdatfile, SDATIO_DOUBLE, "y", "y", "Values of the y coordinate", "m")
	call create_variable(sdatfile, SDATIO_DOUBLE, "t", "t", "Values of the time coordinate", "m")

  call write_variable(sdatfile, "parameter", parameter1)

	call print_variables(sdatfile)
	call create_variable(sdatfile, SDATIO_INT, "iky", "y", "y index values", "(none)")

	call write_variable(sdatfile, "y", yvar)
	call write_variable(sdatfile, "iky", iy)
	call write_variable(sdatfile, "phi", phivar)
	call write_variable(sdatfile, "floatvar", floatvar)


  write (*,*) 'y', yvar

	!find_variable(sdatfile, "parameter")
  !svar2 = svar(1)
  !write (*,*) 'id', svar%type_size
	!call write_variable(sdatfile, "parameter", c_address(parameter1));
  call closefile(sdatfile)

end program test
