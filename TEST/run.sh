#!/bin/sh
set -x
../rez --read-png dot.png 1 --vectorize 128 0 --write-svg OUT/dot.svg 0.1 --write-obj OUT/dot.obj 2.5
../rez --read-png square.png 1 --vectorize 128 0 --write-svg OUT/square.svg 0.1 --write-obj OUT/square.obj 2.5
../rez --read-png thin_line.png 1 --vectorize 128 0 --write-svg OUT/thin_line.svg 0.1 --write-obj OUT/thin_line.obj 2.5
../rez --read-png thick_line.png 1 --vectorize 128 0 --write-svg OUT/thick_line.svg 0.1 --write-obj OUT/thick_line.obj 2.5
../rez --read-png test.png 1 --vectorize 128 0 --write-svg OUT/test.svg 0.1 --write-obj OUT/test.obj 2.5
../rez --read-png test.png 1 --vectorize 128 0.01 --write-svg OUT/test_2.svg 0.1 --write-obj OUT/test_2.obj 2.5
../rez --read-png blueprint.png 0.03 --vectorize 128 0 --write-svg OUT/blueprint.svg 1 --write-obj OUT/blueprint.obj 2.5
../rez --read-png blueprint.png 0.03 --vectorize 128 0.2 --write-svg OUT/blueprint_2.svg 1 --write-obj OUT/blueprint_2.obj 2.5
../rez --read-png blueprint.png 0.03 --vectorize 128 0.5 --write-svg OUT/blueprint_3.svg 1 --write-obj OUT/blueprint_3.obj 2.5
