#!/bin/sh
set -x
dmd -O -inline -m64 rez.d color.d png.d
rm *.o
