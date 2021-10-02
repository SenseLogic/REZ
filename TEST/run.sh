#!/bin/sh
set -x
..\rez --read-png scan.png 64 255 255 0 --trace 128 4.12@3:2 --write-png OUT/scan.png
..\rez --read-png scan.png 64 255 255 0 --trace 128 4.12@0:4/180 --binarize 128 --write-masks OUT/scan_mask_ --write-png OUT/scan_2.png
../rez --read-png dot.png --vectorize 128 0 --write-svg OUT/dot.svg 0.1 --write-obj OUT/dot.obj 1 2.5
../rez --read-png square.png --vectorize 128 0 --write-svg OUT/square.svg 0.1 --write-obj OUT/square.obj 1 2.5
../rez --read-png thin_line.png --vectorize 128 0 --write-svg OUT/thin_line.svg 0.1 --write-obj OUT/thin_line.obj 1 2.5
../rez --read-png thick_line.png --vectorize 128 0 --write-svg OUT/thick_line.svg 0.1 --write-obj OUT/thick_line.obj 1 2.5
../rez --read-png test.png --vectorize 128 0 --write-svg OUT/test.svg 0.1 --write-obj OUT/test.obj 1 2.5
../rez --read-png test.png --vectorize 128 0.01 --write-svg OUT/test_2.svg 0.1 --write-obj OUT/test_2.obj 1 2.5
../rez --read-png blueprint.png --vectorize 128 0 --write-svg OUT/blueprint.svg 1 --write-obj OUT/blueprint.obj 0.03 2.5
../rez --read-png blueprint.png --vectorize 128 0.2 --write-svg OUT/blueprint_2.svg 1 --write-obj OUT/blueprint_2.obj 0.03 2.5
../rez --read-png blueprint.png --vectorize 128 0.5 --write-svg OUT/blueprint_3.svg 1 --write-obj OUT/blueprint_3.obj 0.03 2.5
