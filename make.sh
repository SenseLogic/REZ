#!/bin/sh
set -x
dmd -m64 rez.d core.d color.d png.d
rm *.o
