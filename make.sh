#!/bin/sh
set -x
dmd -m64 rez.d color.d png.d
rm *.o
