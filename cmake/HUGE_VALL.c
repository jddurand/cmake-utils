#if HAVE_MATH_H
#include <math.h>
#endif
#ifdef HAVE_HUGE_VALL_REPLACEMENT_
#  undef HUGE_VALL
#  define HUGE_VALL (__builtin_huge_val())
#endif
int main() {
  double x = -C_HUGE_VALL;
  return 0;
}
