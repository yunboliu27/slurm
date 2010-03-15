##*****************************************************************************
#  $Id$
##*****************************************************************************
#  AUTHOR:
#    Morris Jette <jette1@llnl.gov>
#
#  SYNOPSIS:
#    X_AC_AFFINITY
#
#  DESCRIPTION:
#    Test for various task affinity functions and set the definitions.
#
#  WARNINGS:
#    This macro must be placed after AC_PROG_CC or equivalent.
##*****************************************************************************

AC_DEFUN([X_AC_AFFINITY], [

# Test if sched_setaffinity function exists and argument count (it can vary)
  AC_CHECK_FUNCS(sched_setaffinity, [have_sched_setaffinity=yes])

  AC_COMPILE_IFELSE([AC_LANG_PROGRAM([[#define _GNU_SOURCE
    #include <sched.h>]], [[cpu_set_t mask;
    sched_getaffinity(0, sizeof(cpu_set_t), &mask);]])],[AC_DEFINE(SCHED_GETAFFINITY_THREE_ARGS, 1,
             [Define to 1 if sched_getaffinity takes three arguments.])],[])

  AC_COMPILE_IFELSE([AC_LANG_PROGRAM([[#define _GNU_SOURCE
    #include <sched.h>]], [[cpu_set_t mask;
    sched_getaffinity(0, &mask);]])],[AC_DEFINE(SCHED_GETAFFINITY_TWO_ARGS, 1,
             [Define to 1 if sched_getaffinity takes two arguments.])],[])

#
# Test for NUMA memory afffinity functions and set the definitions
#
  AC_CHECK_LIB([numa],
        [numa_available],
        [ac_have_numa=yes; NUMA_LIBS="-lnuma"])

  AC_SUBST(NUMA_LIBS)
  AM_CONDITIONAL(HAVE_NUMA, test "x$ac_have_numa" = "xyes")
  if test "x$ac_have_numa" = "xyes"; then
    AC_DEFINE(HAVE_NUMA, 1, [define if numa library installed])
    CFLAGS="-DNUMA_VERSION1_COMPATIBILITY $CFLAGS"
  else
    AC_MSG_WARN([Unable to locate NUMA memory affinity functions])
  fi

#
# Test for PLPA functions (see http://www.open-mpi.org/software/plpa)
#
  AC_CHECK_LIB([plpa],
	[plpa_sched_getaffinity],
	[ac_have_plpa=yes; PLPA_LIBS="-rpath /usr/local/lib -lplpa"])

  AC_SUBST(PLPA_LIBS)
  if test "x$ac_have_plpa" = "xyes"; then
    have_sched_setaffinity=yes
    AC_DEFINE(HAVE_PLPA, 1, [define if plpa library installed])
  else
    AC_MSG_WARN([Unable to locate PLPA processor affinity functions])
  fi

#
# Test for cpusets
#
  if test -d "/dev/cpuset" ; then
     have_sched_setaffinity=yes
  fi

#
# Test for other affinity functions as appropriate
# TBD
#

#
# Set HAVE_SCHED_SETAFFINITY if any task affinity supported
AM_CONDITIONAL(HAVE_SCHED_SETAFFINITY, test "x$have_sched_setaffinity" = "xyes")
])
