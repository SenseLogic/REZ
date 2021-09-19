![](https://github.com/senselogic/REZ/blob/master/LOGO/rez.png)

# Rez

Raster image vectorizer.

## Installation

Install the [DMD 2 compiler](https://dlang.org/download.html) (using the MinGW setup option on Windows).

Build the executable with the following command line :

```bash
dmd -m64 rez.d color.d png.d
```

## Command line

```bash
rez [options]
```

### Options

```bash
--read-png <image path> <pixel size> : read a PNG image
--binarize <minimum luminance> : binarize the image
--invert : invert the image
--vectorize <drawing color> <maximum color distance> <polygon height> : vectorize the edges
--write-svg <drawing path> : save the edges in SVG format
--write-obj <mesh path> : save the edges in OBJ format
```

### Examples

```bash
rez --read-png test.png 1 --vectorize 255.255.255 128 2.5 --write-svg OUT/test.svg --write-obj OUT/test.obj
```

Vectorize an image and save the edges in SVG and OBJ format.

![](https://github.com/senselogic/NEBULA/blob/master/TEST/test.png)

![](https://github.com/senselogic/NEBULA/blob/master/TEST/OUT/test.svg)

![](https://github.com/senselogic/NEBULA/blob/master/SCREENSHOT/test.png)

## Dependencies

*   [ARSD PNG library](https://github.com/adamdruppe/arsd)

## Limitations

Only supports PNG files.

## Version

0.1

## Author

Eric Pelzer (ecstatic.coder@gmail.com).

## License

This project is licensed under the GNU General Public License version 3.

See the [LICENSE.md](LICENSE.md) file for details.
