#line 233 "/home/unal/Documents/memory_behaviors/bench/apps/parsec/pkgs/libs/parmacs/inst/x86_64-linux.gcc.gcc/m4/parmacs.pthreads.c.m4"

#line 1 "grav.H"
#ifndef _GRAV_H_
#define _GRAV_H_

void hackgrav(bodyptr p, long ProcessId);
void gravsub(register nodeptr p, long ProcessId);
void hackwalk(long ProcessId);
void walksub(nodeptr n, real dsq, long ProcessId);
bool subdivp(register nodeptr p, real dsq, long ProcessId);

#endif
