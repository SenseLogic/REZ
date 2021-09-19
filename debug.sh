#!/bin/sh
set -x
dmd -debug -g -gf -gs -m64 rez.d color.d png.d
rm *.o
