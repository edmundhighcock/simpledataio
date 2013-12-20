program test
  use simpledataio
  implicit none
  type (sdatio_file) :: sdatfile

  call createfile(sdatfile, "test.cdf")
	call add_dimension(sdatfile, "x", 3, "The x coordinate", "m")
	call add_dimension(sdatfile, "y", 2, "The y coordinate", "m")
	call add_dimension(sdatfile, "t", SDATIO_UNLIMITED, "The time coordinate", "s")
  call print_dimensions(sdatfile)

	call create_variable(sdatfile, SDATIO_DOUBLE, "phi", "xy", "Some potential", "Vm")
	call create_variable(sdatfile, SDATIO_DOUBLE, "parameter", "", "A scalar parameter", "(none)")
	call create_variable(sdatfile, SDATIO_FLOAT, "floatvar", "y", "A single precision variable.", "Vm")
	call create_variable(sdatfile, SDATIO_DOUBLE, "phi_t", "ty", "Some potential as a function of y and time", "Vm")
	call create_variable(sdatfile, SDATIO_DOUBLE, "y", "y", "Values of the y coordinate", "m")
	call create_variable(sdatfile, SDATIO_DOUBLE, "t", "t", "Values of the time coordinate", "m")
  call closefile(sdatfile)

end program test
