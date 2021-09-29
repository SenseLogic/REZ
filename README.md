![](https://github.com/senselogic/REZ/blob/master/LOGO/rez.png)

# Rez

Raster image edge vectorizer.

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
--read-png <image path> [minimum luminance] [maximum luminance] [first luminance] [last luminance] : read an image in PNG format
--trace <maximum opacity distance> <stamp definition> ... : trace the lines
--vectorize <minimum luminance> <maximum position distance> : vectorize the edges
--write-png <image path> [pixel color] : write the image in PNG format
--write-svg <drawing path> [line width] [line color] : write the edges in SVG format
--write-obj <mesh path> [pixel size] [edge height] : write the edges in OBJ format
```

### Examples

```bash
rez --read-png test.png 64 255 --trace 128 4.12@3:2 --write-png OUT/test.png
```

Trace the lines of an image and write them in PNG format.

```bash
rez --read-png test.png --vectorize 128 0.5 --write-svg OUT/test.svg 1 --write-obj OUT/test.obj 0.01 2.5
```

Vectorize the edges of an image and write them in SVG and OBJ format.

![](https://github.com/senselogic/REZ/blob/master/SCREENSHOT/blueprint.png)

![](https://github.com/senselogic/REZ/blob/master/SCREENSHOT/blueprint_2_svg.png)

![](https://github.com/senselogic/REZ/blob/master/SCREENSHOT/blueprint_3_svg.png)

![](https://github.com/senselogic/REZ/blob/master/SCREENSHOT/blueprint_3_obj.png)

## Dependencies

*   [ARSD PNG library](https://github.com/adamdruppe/arsd)

## Limitations

Only supports PNG files.

## Version

1.0

## Author

Eric Pelzer (ecstatic.coder@gmail.com).

## License

This project is licensed under the GNU General Public License version 3.

See the [LICENSE.md](LICENSE.md) file for details.
