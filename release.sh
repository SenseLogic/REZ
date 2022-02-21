#!/bin/sh
set -x
dmd -O -m64 rez.d color.d png.d
rm *.o
