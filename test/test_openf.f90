program test
  use simpledataio
  use simpledataio_write
  use simpledataio_read
  implicit none
  type (sdatio_file) :: sdatfile
!  type (sdatio_variable), pointer :: svar
!  type (sdatio_variable) :: svar2
  real :: parameter1 = 0.5
  double precision, dimension(2) :: yvar = (/0.1d0, 0.3d0/)
  real, dimension(2) :: floatvar = (/0.1,0.3/)
  integer, dimension(2) :: iy = (/1,2/)
  !double precision, dimension(3,2) ::  phivar = (/(/0.1,0.3/), (/2.0, 4.0/), (/-1.0, 3.6/)/);
  double precision, dimension(3,2) ::  phivar = reshape((/0.1d0,2.0d0,-1.0d0, 0.3d0,4.0d0, 3.6d0/), (/3,2/))
  complex*16 , dimension(3,2) ::  phicomp
  complex :: parameter_comp 
  double precision, dimension(2) :: phi_tvar
  !write (*, *) 'phivar', phivar(2,1)
  integer :: i
  double precision :: t
  integer, dimension(2) ::  idxs
  integer, dimension(2) :: idxs2 = (/2,1/)
  double precision ::  val = 32.9
  !complex :: ZI = 

  phicomp = cmplx(phivar, phivar*2.0d0) ! for some reason this results in a loss
    ! of precision
  phicomp =  phivar + phivar*cmplx(0.0,2.0)
  parameter_comp =  cmplx(4.0, 5.0)
  write (*,*) 'phicomp(1,1) is ', phicomp(1,1)

  call system("cp test/testdatf.cdf test/testdatftmp.cdf")
  call sdatio_init(sdatfile, "test/testdatftmp.cdf")
  call open_file(sdatfile)
  call print_dimensions(sdatfile)

  call print_variables(sdatfile)
  call set_count(sdatfile, "phi_txy", "x", 1)
  call set_count(sdatfile, "phi_txy", "y", 1)
  call write_variable(sdatfile, "phi_txy", phicomp)


  do i = 1,6
    t = 0.3d0 + real(i);
    phi_tvar(1) = 4 + real(i)/2.0;
    phi_tvar(2) = 6 + real(i)*3.0; 
    call write_variable(sdatfile, "t", t)
    call write_variable(sdatfile, "phi_t", phi_tvar)
    
    call set_offset(sdatfile, "phi_txy", "x", 1)

    call set_start(sdatfile, "phi_txy", "x", 2)
    call write_variable_with_offset(sdatfile, "phi_txy", phicomp)

    call set_start(sdatfile, "phi_txy", "y", 2)
    call write_variable(sdatfile, "phi_txy", parameter_comp)
    call set_start(sdatfile, "phi_txy", "y", 1)

    call set_start(sdatfile, "phi_txy", "x", 3)
    call write_variable_with_offset(sdatfile, "phi_txy", phicomp)


    call increment_start(sdatfile, "t");
    ! if (i>2) stop
  end do

  call closefile(sdatfile)
  call sdatio_free(sdatfile)

  call sdatio_init(sdatfile, "test/testdatftmp.cdf")
  call open_file(sdatfile)

  phi_tvar(2) = -10.0
  write (*,*) 'phi_tvar set is', phi_tvar(2), 6 + 6.0*3.0
  call read_variable(sdatfile, "phi_t", phi_tvar)
  write (*,*) 'phi_tvar read is', phi_tvar(2), 6 + 6.0*3.0
  call read_variable(sdatfile, "t", t)

  call set_dimension_start(sdatfile, "t", 3)

  call write_variable(sdatfile, "t", t)

  call closefile(sdatfile)
  call sdatio_free(sdatfile)

end program test
