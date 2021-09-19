#!/bin/sh
set -x
../rez --read-png dot.png 1 --vectorize 255.255.255 128 0.1 2.5 --write-svg OUT/dot.svg --write-obj OUT/dot.obj
../rez --read-png square.png 1 --vectorize 255.255.255 128 0.1 2.5 --write-svg OUT/square.svg --write-obj OUT/square.obj
../rez --read-png thin_line.png 1 --vectorize 255.255.255 128 0.1 2.5 --write-svg OUT/thin_line.svg --write-obj OUT/thin_line.obj
../rez --read-png thick_line.png 1 --vectorize 255.255.255 128 0.1 2.5 --write-svg OUT/thick_line.svg --write-obj OUT/thick_line.obj
../rez --read-png test.png 1 --vectorize 255.255.255 128 0.1 2.5 --write-svg OUT/test.svg --write-obj OUT/test.obj
../rez --read-png blueprint.png 0.03 --vectorize 255.255.255 128 1 2.5 --write-svg OUT/blueprint.svg --write-obj OUT/blueprint.obj
