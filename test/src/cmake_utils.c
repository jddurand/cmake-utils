#include <stdio.h>
#include <cmake_utils.h>

void cmake_utils_FASTCALL f(char *s) {
  fprintf(stdout, "%s\n", s);
  fflush(stdout);
}
