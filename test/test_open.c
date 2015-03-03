#include "stdio.h"
#include "include/simpledataio.h"

int main (int argc, char ** argv){
  struct sdatio_file sdatfile;
  struct sdatio_file sdatfile2;
  double yvar[2] = {0.1,0.3};
  float floatvar[2] = {0.1,0.3};
  int iy[2] = {1,2};
  double phivar[3][2] = {{0.1,0.3}, {2.0, 4.0}, {-1.0, 3.6}};
  double t;
  double phi_tvar[2];
  double parameter = 0.5;
  int i;
  int j = 4;

  sdatio_debug = 1;

  system("cp test/testdata.cdf test/testdatatmp.cdf");
  sdatio_init(&sdatfile, "test/testdatatmp.cdf");

  sdatio_open_file(&sdatfile);

  sdatio_print_dimensions(&sdatfile);

  sdatio_print_variables(&sdatfile);

  for (i=0;i<6;i++){
    t = 0.3 + i;
    phi_tvar[0] = 4 + i/2.0;
    phi_tvar[1] = 6 + i*3.0; 
    sdatio_write_variable(&sdatfile, "t", &t);
    sdatio_write_variable(&sdatfile, "phi_t", &phi_tvar);
    sdatio_increment_start(&sdatfile, "t");
  }


  sdatio_close(&sdatfile);
  sdatio_free(&sdatfile);

  sdatio_init(&sdatfile2, "test/testdat_long_dim_names.cdf");
  sdatio_open_file(&sdatfile2);
  sdatio_print_dimensions(&sdatfile2);
  sdatio_print_variables(&sdatfile2);
  sdatio_close(&sdatfile2);
  sdatio_free(&sdatfile2);




  printf("Success!\n");
  return 0;
}
