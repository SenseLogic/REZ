![](https://github.com/senselogic/REZ/blob/master/LOGO/rez.png)

# Rez

Raster image line vectorizer.

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
--read-png <image path> [pixel size] [minimum luminance] [maximum luminance] [first luminance] [last luminance] : read an image in PNG format
--trace <maximum opacity distance> <stamp definition> ... : trace the lines
--vectorize <minimum luminance> <maximum_position_distance> <line width> <polygon height>" : vectorize the line edges
--write-png <image path> <pixel color> : write the image in PNG format
--write-svg <drawing path>" : write the line edges in SVG format
--write-obj <mesh path>" : write the line walls in SVG format
```

### Examples

```bash
rez --read-png test.png 0.01 --vectorize 128 0.5 1 2.5 --write-svg OUT/test.svg --write-obj OUT/test.obj
```

Vectorize an image and save the line edges in SVG format and the line walls in OBJ format.

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
