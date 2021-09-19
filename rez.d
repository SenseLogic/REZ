/*
    This file is part of the Rez distribution.

    https://github.com/senselogic/REZ

    Copyright (C) 2017 Eric Pelzer (ecstatic.coder@gmail.com)

    Rez is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, version 3.

    Rez is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Rez.  If not, see <http://www.gnu.org/licenses/>.
*/

// -- IMPORTS

import arsd.color : Color, MemoryImage, TrueColorImage;
import arsd.png : readPng, writePng;
import core.stdc.stdlib : exit;
import std.conv : to;
import std.math : sqrt;
import std.stdio : writeln, File;
import std.string : endsWith, format, indexOf, split, startsWith;

// -- TYPES

struct VECTOR_2
{
    // -- ATTRIBUTES

    double
        X = 0.0,
        Y = 0.0;

    // -- OPERATIONS

    void SetAverageVector(
        ref VECTOR_2 first_vector,
        ref VECTOR_2 second_vector
        )
    {
        X = ( first_vector.X + second_vector.X ) * 0.5;
        Y = ( first_vector.Y + second_vector.Y ) * 0.5;
    }

    // ~~

    void SetInterpolatedVector(
        ref VECTOR_2 first_vector,
        ref VECTOR_2 second_vector,
        double interpolation_factor
        )
    {
        X = first_vector.X + ( second_vector.X - first_vector.X ) * interpolation_factor;
        Y = first_vector.Y + ( second_vector.Y - first_vector.Y ) * interpolation_factor;
    }
}

// ~~

struct VECTOR_3
{
    // -- ATTRIBUTES

    double
        X = 0.0,
        Y = 0.0,
        Z = 0.0;

    // -- INQUIRIES

    double GetDistance(
        ref VECTOR_3 position_vector
        )
    {
        double
            x_distance,
            y_distance,
            z_distance;

        x_distance = position_vector.X - X;
        y_distance = position_vector.Y - Y;
        z_distance = position_vector.Z - Z;

        return sqrt( x_distance * x_distance + y_distance * y_distance + z_distance * z_distance );
    }

    // -- OPERATIONS

    void SetNull(
        )
    {
        X = 0.0;
        Y = 0.0;
        Z = 0.0;
    }

    // ~~

    void SetUnit(
        )
    {
        X = 1.0;
        Y = 1.0;
        Z = 1.0;
    }

    // ~~

    void AddVector(
        ref VECTOR_3 vector
        )
    {
        X += vector.X;
        Y += vector.Y;
        Z += vector.Z;
    }

    // ~~

    void AddScaledVector(
        ref VECTOR_3 vector,
        double factor
        )
    {
        X += vector.X * factor;
        Y += vector.Y * factor;
        Z += vector.Z * factor;
    }

    // ~~

    void MultiplyScalar(
        double scalar
        )
    {
        X *= scalar;
        Y *= scalar;
        Z *= scalar;
    }

    // ~~

    void SetAverageVector(
        ref VECTOR_3 first_vector,
        ref VECTOR_3 second_vector
        )
    {
        X = ( first_vector.X + second_vector.X ) * 0.5;
        Y = ( first_vector.Y + second_vector.Y ) * 0.5;
        Z = ( first_vector.Z + second_vector.Z ) * 0.5;
    }

    // ~~

    void Clip(
        ref VECTOR_3 minimum_vector,
        ref VECTOR_3 maximum_vector
        )
    {
        if ( X < minimum_vector.X )
        {
            X = minimum_vector.X;
        }

        if ( Y < minimum_vector.Y )
        {
            Y = minimum_vector.Y;
        }

        if ( Z < minimum_vector.Z )
        {
            Z = minimum_vector.Z;
        }

        if ( X > maximum_vector.X )
        {
            X = maximum_vector.X;
        }

        if ( Y > maximum_vector.Y )
        {
            Y = maximum_vector.Y;
        }

        if ( Z > maximum_vector.Z )
        {
            Z = maximum_vector.Z;
        }
    }

    // ~~

    void Translate(
        double x_translation,
        double y_translation,
        double z_translation
        )
    {
        X += x_translation;
        Y += y_translation;
        Z += z_translation;
    }

    // ~~

    void Scale(
        double x_scaling,
        double y_scaling,
        double z_scaling
        )
    {
        X *= x_scaling;
        Y *= y_scaling;
        Z *= z_scaling;
    }

    // ~~

    void RotateAroundX(
        double x_angle_cosinus,
        double x_angle_sinus
        )
    {
        double
            y;

        y = Y;
        Y = Y * x_angle_cosinus - Z * x_angle_sinus;
        Z = y * x_angle_sinus + Z * x_angle_cosinus;
    }

    // ~~

    void RotateAroundY(
        double y_angle_cosinus,
        double y_angle_sinus
        )
    {
        double
            x;

        x = X;
        X = X * y_angle_cosinus + Z * y_angle_sinus;
        Z = Z * y_angle_cosinus - x * y_angle_sinus;
    }

    // ~~

    void RotateAroundZ(
        double z_angle_cosinus,
        double z_angle_sinus
        )
    {
        double
            x,
            y;

        x = X;
        X = X * z_angle_cosinus - Y * z_angle_sinus;
        Y = x * z_angle_sinus + Y * z_angle_cosinus;
    }

    // ~~

    void SetInterpolatedVector(
        ref VECTOR_3 first_vector,
        ref VECTOR_3 second_vector,
        double interpolation_factor
        )
    {
        X = first_vector.X + ( second_vector.X - first_vector.X ) * interpolation_factor;
        Y = first_vector.Y + ( second_vector.Y - first_vector.Y ) * interpolation_factor;
        Z = first_vector.Z + ( second_vector.Z - first_vector.Z ) * interpolation_factor;
    }
}

// ~~

struct VECTOR_4
{
    // -- ATTRIBUTES

    double
        X = 0.0,
        Y = 0.0,
        Z = 0.0,
        W = 0.0;

    // -- OPERATIONS

    void SetNull(
        )
    {
        X = 0.0;
        Y = 0.0;
        Z = 0.0;
        W = 0.0;
    }

    // ~~

    void SetUnit(
        )
    {
        X = 1.0;
        Y = 1.0;
        Z = 1.0;
        W = 1.0;
    }

    // ~~

    void AddVector(
        ref VECTOR_4 vector
        )
    {
        X += vector.X;
        Y += vector.Y;
        Z += vector.Z;
        W += vector.W;
    }

    // ~~

    void MultiplyScalar(
        double scalar
        )
    {
        X *= scalar;
        Y *= scalar;
        Z *= scalar;
        W *= scalar;
    }

    // ~~

    void SetAverageVector(
        ref VECTOR_4 first_vector,
        ref VECTOR_4 second_vector
        )
    {
        X = ( first_vector.X + second_vector.X ) * 0.5;
        Y = ( first_vector.Y + second_vector.Y ) * 0.5;
        Z = ( first_vector.Z + second_vector.Z ) * 0.5;
        W = ( first_vector.W + second_vector.W ) * 0.5;
    }

    // ~~

    void Translate(
        double x_translation,
        double y_translation,
        double z_translation,
        double w_translation
        )
    {
        X += x_translation;
        Y += y_translation;
        Z += z_translation;
        W += w_translation;
    }

    // ~~

    void Scale(
        double x_scaling,
        double y_scaling,
        double z_scaling,
        double w_scaling
        )
    {
        X *= x_scaling;
        Y *= y_scaling;
        Z *= z_scaling;
        W *= w_scaling;
    }

    // ~~

    void SetInterpolatedVector(
        ref VECTOR_4 first_vector,
        ref VECTOR_4 second_vector,
        double interpolation_factor
        )
    {
        X = first_vector.X + ( second_vector.X - first_vector.X ) * interpolation_factor;
        Y = first_vector.Y + ( second_vector.Y - first_vector.Y ) * interpolation_factor;
        Z = first_vector.Z + ( second_vector.Z - first_vector.Z ) * interpolation_factor;
        W = first_vector.W + ( second_vector.W - first_vector.W ) * interpolation_factor;
    }
}

// ~~

struct COLOR
{
    // -- ATTRIBUTES

    ubyte
        Red,
        Green,
        Blue,
        Alpha = 255;

    // -- INQUIRIES

    long GetLuminance(
        )
    {
        return
            ( cast( long )Red * 77
              + cast( long )Green * 151
              + cast( long )Blue * 28 ) >> 8;
    }

    // ~~

    long GetSquareDistance(
        COLOR color
        )
    {
        long
            blue_offset,
            green_offset,
            red_mean,
            red_offset,
            square_distance;

        red_mean = ( cast( long )Red + cast( long )color.Red ) >> 1;
        red_offset = cast( long )Red - cast( long )color.Red;
        green_offset = cast( long )Green - cast( long )color.Green;
        blue_offset = cast( long )Blue - cast( long )color.Blue;

        return
            ( ( ( 512 + red_mean ) * red_offset * red_offset ) >> 8 )
            + 4 * green_offset * green_offset
            + ( ( ( 767 - red_mean ) * blue_offset * blue_offset ) >> 8 );
    }

    // -- OPERATIONS

    void SetFromText(
        string text
        )
    {
        string[]
            part_array;

        try
        {
            part_array = text.split( '.' );

            Red = part_array[ 0 ].to!ubyte();
            Green = part_array[ 1 ].to!ubyte();
            Blue = part_array[ 2 ].to!ubyte();

            if ( part_array.length == 4 )
            {
                Alpha = part_array[ 3 ].to!ubyte();
            }
            else
            {
                Alpha = 255;
            }
        }
        catch ( Exception exception )
        {
            Abort( "Invalid color : " ~ text );
        }
    }

    // ~~

    void Binarize(
        long minimum_luminance = 128
        )
    {
        if ( GetLuminance() < minimum_luminance )
        {
            Red = 0;
            Green = 0;
            Blue = 0;
        }
        else
        {
            Red = 255;
            Green = 255;
            Blue = 255;
        }
    }

    // ~~

    void Invert(
        )
    {
        Red = 255 - Red;
        Green = 255 - Red;
        Blue = 255 - Red;
    }
}

// ~~

alias PIXEL = COLOR;

// ~~

class IMAGE
{
    // -- ATTRIBUTES

    double
        PixelSize;
    long
        ColumnCount,
        LineCount;
    PIXEL[]
        PixelArray;

    // -- INQUIRIES

    long GetPixelIndex(
        long column_index,
        long line_index
        )
    {
        assert(
            column_index >= 0
            && column_index < ColumnCount
            && line_index >= 0
            && line_index < LineCount
            );

        return line_index * ColumnCount + column_index;
    }

    // ~~

    PIXEL GetPixel(
        long column_index,
        long line_index
        )
    {
        return PixelArray[ GetPixelIndex( column_index, line_index ) ];
    }

    // ~~

    bool HasPixel(
        long column_index,
        long line_index,
        COLOR color,
        long maximum_color_distance
        )
    {
        return
            column_index >= 0
            && column_index < ColumnCount
            && line_index >= 0
            && line_index < LineCount
            && PixelArray[ line_index * ColumnCount + column_index ].Alpha >= 128
            && PixelArray[ line_index * ColumnCount + column_index ].GetSquareDistance( color )
               <= maximum_color_distance * maximum_color_distance;
    }

    // -- OPERATIONS

    void SetPixel(
        long column_index,
        long line_index,
        PIXEL pixel
        )
    {
        PixelArray[ GetPixelIndex( column_index, line_index ) ] = pixel;
    }

    // ~~

    void ReadPngFile(
        string file_path,
        double pixel_size
        )
    {
        long
            column_index,
            line_index;
        Color
            color;
        TrueColorImage
            true_color_image;
        PIXEL
            pixel;

        writeln( "Loading image : ", file_path );

        PixelSize = pixel_size;

        true_color_image = readPng( file_path ).getAsTrueColorImage();

        LineCount = true_color_image.height();
        ColumnCount = true_color_image.width();
        PixelArray.length = LineCount * ColumnCount;

        writeln( "    Line count : ", LineCount );
        writeln( "    Column count : ", ColumnCount );

        for ( line_index = 0;
              line_index < LineCount;
              ++line_index )
        {
            for ( column_index = 0;
                  column_index < ColumnCount;
                  ++column_index )
            {
                color = true_color_image.getPixel( cast( int )column_index, cast( int )line_index );

                pixel.Red = color.r;
                pixel.Green = color.g;
                pixel.Blue = color.b;
                pixel.Alpha = color.a;

                SetPixel( column_index, line_index, pixel );
            }
        }
    }

    // ~~

    void Binarize(
        ulong minimum_luminance
        )
    {
        writeln( "Binarizing image" );
        writeln( "    Minimum luminance : ", minimum_luminance );

        foreach ( ref pixel; PixelArray )
        {
            pixel.Binarize( minimum_luminance );
        }
    }

    // ~~

    void Invert(
        )
    {
        writeln( "Inverting image" );

        foreach ( ref pixel; PixelArray )
        {
            pixel.Invert();
        }
    }
}

// ~~

struct EDGE
{
    // -- ATTRIBUTES

    long
        ColumnIndex,
        LineIndex,
        Direction,
        PixelCount,
        PolygonIndex;
    VECTOR_2
        PositionVector,
        OldPositionVector;
    bool
        IsRemoved;

    // -- INQUIRIES

    bool IsUnused(
        )
    {
        return
            PixelCount > 0
            && PolygonIndex < 0;
    }
}

// ~~

struct POINT
{
    // -- ATTRIBUTES

    bool
        HasPixel;
    EDGE[ 4 ]
        EdgeArray;
}

// ~~

struct POLYGON
{
    // -- ATTRIBUTES

    EDGE[]
        EdgeArray;

    // -- OPERATIONS

    void Pack(
        )
    {
        long
            edge_count;

        edge_count = 0;

        foreach ( edge_index, ref edge; EdgeArray )
        {
            if ( !edge.IsRemoved )
            {
                if ( edge_index > edge_count )
                {
                    EdgeArray[ edge_count ] = edge;
                }

                ++edge_count;
            }
        }

        EdgeArray.length = edge_count;
    }

    // ~~

    void Smooth(
        )
    {
        double
            interpolation_factor;
        long
            edge_index,
            next_edge_index,
            prior_edge_index;

        foreach ( ref edge; EdgeArray )
        {
            edge.OldPositionVector = edge.PositionVector;
        }

        for ( edge_index = 0;
              edge_index < EdgeArray.length;
              ++edge_index )
        {
            prior_edge_index = edge_index - 1;

            if ( prior_edge_index < 0 )
            {
                prior_edge_index += EdgeArray.length;
            }

            next_edge_index = edge_index + 1;

            if ( next_edge_index >= EdgeArray.length )
            {
                next_edge_index -= EdgeArray.length;
            }

            if ( EdgeArray[ edge_index ].PixelCount == 1
                 && EdgeArray[ next_edge_index ].Direction == EdgeArray[ prior_edge_index ].Direction )
            {
                interpolation_factor
                    = EdgeArray[ next_edge_index ].PixelCount.to!double()
                      / ( EdgeArray[ prior_edge_index ].PixelCount
                          + EdgeArray[ next_edge_index ].PixelCount ).to!double();

                EdgeArray[ next_edge_index ].PositionVector.SetInterpolatedVector(
                    EdgeArray[ edge_index ].OldPositionVector,
                    EdgeArray[ next_edge_index ].OldPositionVector,
                    interpolation_factor
                    );

                EdgeArray[ edge_index ].IsRemoved = true;

                ++edge_index;
            }
        }

        Pack();
    }
}

// ~~

class DRAWING
{
    // -- ATTRIBUTES

    double
        PixelSize,
        LineWidth;
    long
        ColumnCount,
        LineCount;
    POINT[]
        PointArray;
    POLYGON[]
        PolygonArray;
    double
        PolygonHeight;

    // -- INQUIRIES

    long GetPointIndex(
        long column_index,
        long line_index
        )
    {
        assert(
            column_index >= 0
            && column_index < ColumnCount
            && line_index >= 0
            && line_index < LineCount
            );

        return line_index * ColumnCount + column_index;
    }

    // ~~

    bool HasPixel(
        long column_index,
        long line_index
        )
    {
        return
            column_index >= 0
            && column_index < ColumnCount
            && line_index >= 0
            && line_index < LineCount
            && PointArray[ line_index * ColumnCount + column_index ].HasPixel;
    }

    // ~~

    bool HasEdge(
        long column_index,
        long line_index,
        long direction
        )
    {
        if ( direction == 0 )
        {
            return
                HasPixel( column_index, line_index )
                && !HasPixel( column_index, line_index - 1 );
        }
        else if ( direction == 1 )
        {
            return
                HasPixel( column_index - 1, line_index )
                && !HasPixel( column_index, line_index );
        }
        else if ( direction == 2 )
        {
            return
                HasPixel( column_index - 1, line_index - 1 )
                && !HasPixel( column_index - 1, line_index );
        }
        else
        {
            assert( direction == 3 );

            return
                HasPixel( column_index, line_index - 1 )
                && !HasPixel( column_index - 1, line_index - 1 );
        }
    }

    // ~~

    VECTOR_3 GetPositionVector(
        ref EDGE edge,
        double height
        )
    {
        VECTOR_3
            position_vector;

        position_vector.X = ( edge.PositionVector.X - ( ColumnCount - 1 ).to!double() * 0.5 ) * PixelSize;
        position_vector.Y = -( edge.PositionVector.Y - ( LineCount - 1 ).to!double() * 0.5 ) * PixelSize;
        position_vector.Z = height;

        return position_vector;
    }

    // ~~

    void WriteSvgFile(
        string file_path
        )
    {
        long
            edge_index;
        File
            file;
        EDGE
            edge;

        writeln( "Writing drawing : ", file_path );

        try
        {
            file.open( file_path, "w" );
            file.write(
                "<svg width=\""
                ~ ( ColumnCount - 1 ).to!string()
                ~ "\" height=\""
                ~ ( LineCount - 1 ).to!string()
                ~ "\" xmlns=\"http://www.w3.org/2000/svg\">\n"
                );
            file.write( "<g>\n" );

            foreach ( ref polygon; PolygonArray )
            {
                file.write( "<path d=\"M " );

                for ( edge_index = 0;
                      edge_index <= polygon.EdgeArray.length;
                      ++edge_index )
                {
                    if ( edge_index < polygon.EdgeArray.length )
                    {
                        edge = polygon.EdgeArray[ edge_index ];
                    }
                    else
                    {
                        edge = polygon.EdgeArray[ 0 ];
                    }

                    if ( edge_index > 0 )
                    {
                        file.write( " L " );
                    }

                    file.write(
                        edge.PositionVector.X.GetText(),
                        " ",
                        edge.PositionVector.Y.GetText()
                        );
                }

                file.write(
                    " Z\" stroke=\"#000\" stroke-width=\""
                    ~ LineWidth.GetText()
                    ~ "\" fill=\"none\"/>\n"
                    );
            }

            file.write( "</g>\n" );
            file.write( "</svg>\n" );
            file.close();
        }
        catch ( Exception exception )
        {
            Abort( "Can't write file : " ~ file_path, exception );
        }
    }


    // -- OPERATIONS

    void SetPoints(
        IMAGE image,
        COLOR drawing_color,
        long maximum_color_distance
        )
    {
        long
            column_index,
            direction,
            front_column_offset,
            front_line_offset,
            line_index,
            pixel_count,
            point_index;
        POINT
            point;
        EDGE
            edge;

        LineCount = image.LineCount + 3;
        ColumnCount = image.ColumnCount + 3;
        PointArray.length = LineCount * ColumnCount;

        for ( line_index = 0;
              line_index < image.LineCount;
              ++line_index )
        {
            for ( column_index = 0;
                  column_index < image.ColumnCount;
                  ++column_index )
            {
                point_index = GetPointIndex( column_index + 1, line_index + 1 );

                PointArray[ point_index ].HasPixel
                    = image.HasPixel( column_index, line_index, drawing_color, maximum_color_distance );
            }
        }

        for ( line_index = 0;
              line_index < LineCount;
              ++line_index )
        {
            for ( column_index = 0;
                  column_index < ColumnCount;
                  ++column_index )
            {
                point_index = GetPointIndex( column_index, line_index );

                for ( direction = 0;
                      direction < 4;
                      ++direction )
                {
                    front_column_offset = ColumnOffsetArray[ direction ];
                    front_line_offset = LineOffsetArray[ direction ];

                    pixel_count = 0;

                    while ( HasEdge(
                                column_index + pixel_count * front_column_offset,
                                line_index + pixel_count * front_line_offset,
                                direction
                                ) )
                    {
                        ++pixel_count;
                    }

                    edge.ColumnIndex = column_index;
                    edge.LineIndex = line_index;
                    edge.Direction = direction;
                    edge.PixelCount = pixel_count;
                    edge.PolygonIndex = -1;
                    edge.PositionVector.X = column_index.to!double();
                    edge.PositionVector.Y = line_index.to!double();

                    PointArray[ point_index ].EdgeArray[ direction ] = edge;
                }
            }
        }
    }

    // ~~

    void AddPolygon(
        long column_index,
        long line_index,
        long direction
        )
    {
        long
            polygon_index,
            point_line_index,
            point_column_index,
            edge_direction,
            edge_line_offset,
            edge_column_offset,
            edge_pixel_count,
            edge_left_direction,
            edge_right_direction,
            point_index,
            point_line_offset,
            point_column_offset;
        EDGE
            edge;
        POLYGON
            polygon;

        polygon_index = PolygonArray.length;

        point_column_index = column_index;
        point_line_index = line_index;
        edge_direction = direction;

        do
        {
            point_index = GetPointIndex( point_column_index, point_line_index );
            edge = PointArray[ point_index ].EdgeArray[ edge_direction ];

            assert( edge.IsUnused() );

            polygon.EdgeArray ~= edge;

            edge_direction = edge.Direction;
            edge_pixel_count = edge.PixelCount;

            edge_column_offset = ColumnOffsetArray[ edge_direction ];
            edge_line_offset = LineOffsetArray[ edge_direction ];

            while ( edge_pixel_count > 0 )
            {
                assert( PointArray[ point_index ].EdgeArray[ edge_direction ].PolygonIndex < 0 );

                PointArray[ point_index ].EdgeArray[ edge_direction ].PolygonIndex = polygon_index;

                point_column_index += edge_column_offset;
                point_line_index += edge_line_offset;
                point_index = GetPointIndex( point_column_index, point_line_index );

                --edge_pixel_count;
            }

            edge_left_direction = LeftDirectionArray[ edge_direction ];
            edge_right_direction = RightDirectionArray[ edge_direction ];

            if ( PointArray[ point_index ].EdgeArray[ edge_left_direction ].IsUnused() )
            {
                edge_direction = edge_left_direction;
            }
            else if ( PointArray[ point_index ].EdgeArray[ edge_right_direction ].IsUnused() )
            {
                edge_direction = edge_right_direction;
            }
            else
            {
                break;
            }
        }
        while ( point_column_index != column_index
                || point_line_index != line_index
                || edge_direction != direction );

        assert( polygon.EdgeArray.length >= 4 );

        polygon.Smooth();
        PolygonArray ~= polygon;
    }

    // ~~

    void SetFromImage(
        IMAGE image,
        COLOR drawing_color,
        long maximum_color_distance,
        double line_width
        )
    {
        long
            column_index,
            direction,
            line_index,
            point_index;

        PixelSize = image.PixelSize;
        LineWidth = line_width;

        SetPoints( image, drawing_color, maximum_color_distance );

        for ( line_index = 0;
              line_index < LineCount;
              ++line_index )
        {
            for ( column_index = 0;
                  column_index < ColumnCount;
                  ++column_index )
            {
                point_index = GetPointIndex( column_index, line_index );

                for ( direction = 0;
                      direction < 4;
                      ++direction )
                {
                    if ( PointArray[ point_index ].EdgeArray[ direction ].IsUnused() )
                    {
                        AddPolygon( column_index, line_index, direction );
                    }
                }
            }
        }
    }

    // ~~

    void SetFromImage(
        IMAGE image,
        string drawing_color_text,
        long maximum_color_distance,
        double line_width,
        double polygon_height
        )
    {
        COLOR
            drawing_color;

        writeln( "Vectorizing image" );
        writeln( "    Drawing color : ", drawing_color_text );
        writeln( "    Maximum color distance : ", maximum_color_distance );
        writeln( "    Polygon height : ", polygon_height );

        drawing_color.SetFromText( drawing_color_text );
        SetFromImage( image, drawing_color, maximum_color_distance, line_width );
        PolygonHeight = polygon_height;
    }
}

// ~~

class MESH
{
    // -- ATTRIBUTES

    VECTOR_3[]
        PositionVectorArray;
    long[]
        PositionVectorIndexArray;
    long[ VECTOR_3 ]
        PositionVectorIndexMap;

    // -- INQUIRIES

    void WriteObjFile(
        string file_path
        )
    {
        long
            position_vector_index_index,
            polygon_position_vector_count;
        File
            file;

        writeln( "Writing mesh : ", file_path );

        try
        {
            file.open( file_path, "w" );

            foreach ( ref position_vector; PositionVectorArray )
            {
                file.write(
                    "v ",
                    position_vector.X.GetText(),
                    " ",
                    position_vector.Y.GetText(),
                    " ",
                    position_vector.Z.GetText(),
                    "\n"
                    );
            }

            if ( PositionVectorIndexArray.length > 0 )
            {
                polygon_position_vector_count = 0;

                for ( position_vector_index_index = 0;
                      position_vector_index_index < PositionVectorIndexArray.length;
                      ++position_vector_index_index )
                {
                    if ( PositionVectorIndexArray[ position_vector_index_index ] < 0 )
                    {
                        file.write( "\n" );

                        polygon_position_vector_count = 0;
                    }
                    else
                    {
                        if ( polygon_position_vector_count == 0 )
                        {
                            file.write( "f" );
                        }

                        file.write( " " ~ ( PositionVectorIndexArray[ position_vector_index_index ] + 1 ).GetText() );

                        ++polygon_position_vector_count;
                    }
                }
            }

            file.close();
        }
        catch ( Exception exception )
        {
            Abort( "Can't write file : " ~ file_path, exception );
        }
    }

    // -- OPERATIONS

    void AddPositionVector(
        VECTOR_3 position_vector
        )
    {
        long
            position_vector_index;
        long*
            found_position_vector_index;

        found_position_vector_index = position_vector in PositionVectorIndexMap;

        if ( found_position_vector_index is null )
        {
            position_vector_index = PositionVectorArray.length;
            PositionVectorArray ~= position_vector;
            PositionVectorIndexMap[ position_vector ] = position_vector_index;
        }
        else
        {
            position_vector_index = *found_position_vector_index;
        }

        PositionVectorIndexArray ~= position_vector_index;
    }

    // ~~

    void SetFromDrawing(
        DRAWING drawing
        )
    {
        long
            first_edge_index,
            second_edge_index;

        foreach ( ref polygon; drawing.PolygonArray )
        {
            for ( first_edge_index = 0;
                  first_edge_index < polygon.EdgeArray.length;
                  ++first_edge_index )
            {
                second_edge_index = first_edge_index + 1;

                if ( second_edge_index == polygon.EdgeArray.length )
                {
                    second_edge_index = 0;
                }

                AddPositionVector( drawing.GetPositionVector( polygon.EdgeArray[ second_edge_index ], 0.0 ) );
                AddPositionVector( drawing.GetPositionVector( polygon.EdgeArray[ first_edge_index ], 0.0 ) );
                AddPositionVector( drawing.GetPositionVector( polygon.EdgeArray[ first_edge_index ], drawing.PolygonHeight ) );
                AddPositionVector( drawing.GetPositionVector( polygon.EdgeArray[ second_edge_index ], drawing.PolygonHeight ) );

                PositionVectorIndexArray ~= -1;
            }
        }
    }
}

// -- VARIABLES

long
    DownDirection,
    LeftDirection,
    RightDirection,
    UpDirection;
long[ 4 ]
    ColumnOffsetArray,
    LeftDirectionArray,
    LineOffsetArray,
    RightDirectionArray;

// -- FUNCTIONS

void PrintError(
    string message
    )
{
    writeln( "*** ERROR : ", message );
}

// ~~

void Abort(
    string message
    )
{
    PrintError( message );

    exit( -1 );
}

// ~~

void Abort(
    string message,
    Exception exception
    )
{
    PrintError( message );
    PrintError( exception.msg );

    exit( -1 );
}

// ~~

string GetText(
    long integer
    )
{
    return integer.to!string();
}

// ~~

string GetText(
    double real_
    )
{
    string
        text;

    text = format( "%f", real_ );

    if ( text.indexOf( '.' ) >= 0 )
    {
        while ( text.endsWith( '0') )
        {
            text = text[ 0 .. $ - 1 ];
        }

        if ( text.endsWith( '.' ) )
        {
            text = text[ 0 .. $ - 1 ];
        }
    }

    if ( text == "-0" )
    {
        return "0";
    }
    else
    {
        return text;
    }
}

// ~~

void main(
    string[] argument_array
    )
{
    long
        argument_count;
    string
        input_file_path,
        option,
        output_file_path;
    DRAWING
        drawing;
    IMAGE
        image;
    MESH
        mesh;

    RightDirection = 0;
    DownDirection = 1;
    LeftDirection = 2;
    UpDirection = 3;

    ColumnOffsetArray = [ 1, 0, -1, 0 ];
    LineOffsetArray = [ 0, 1, 0, -1 ];
    LeftDirectionArray = [ UpDirection, RightDirection, DownDirection, LeftDirection ];
    RightDirectionArray = [ DownDirection, LeftDirection, UpDirection, RightDirection ];

    argument_array = argument_array[ 1 .. $ ];

    while ( argument_array.length >= 1
            && argument_array[ 0 ].startsWith( "--" ) )
    {
        option = argument_array[ 0 ];

        argument_array = argument_array[ 1 .. $ ];
        argument_count = 0;

        while ( argument_count < argument_array.length
                && !argument_array[ argument_count ].startsWith( "--" ) )
        {
            ++argument_count;
        }

        if ( option == "--read-png"
             && argument_count == 2 )
        {
            image = new IMAGE();
            image.ReadPngFile(
                argument_array[ 0 ],
                argument_array[ 1 ].to!double()
                );
        }
        else if ( option == "--binarize"
                  && argument_count == 1
                  && image !is null )
        {
            image.Binarize(
                argument_array[ 0 ].to!long()
                );
        }
        else if ( option == "--invert"
                  && argument_count == 0
                  && image !is null )
        {
            image.Invert();
        }
        else if ( option == "--vectorize"
                  && argument_count == 4
                  && image !is null )
        {
            drawing = new DRAWING();
            drawing.SetFromImage(
                image,
                argument_array[ 0 ],
                argument_array[ 1 ].to!long(),
                argument_array[ 2 ].to!double(),
                argument_array[ 3 ].to!double()
                );

            mesh = new MESH();
            mesh.SetFromDrawing( drawing );
        }
        else if ( option == "--write-svg"
                  && argument_count == 1
                  && drawing !is null )
        {
            drawing.WriteSvgFile(
                argument_array[ 0 ]
                );
        }
        else if ( option == "--write-obj"
                  && argument_count == 1
                  && mesh !is null )
        {
            mesh.WriteObjFile(
                argument_array[ 0 ]
                );
        }
        else
        {
            Abort( "Invalid option : " ~ option );
        }

        argument_array = argument_array[ argument_count .. $ ];
    }

    if ( argument_array.length > 0 )
    {
        writeln( "Usage :" );
        writeln( "    rez [options]" );
        writeln( "Options :" );
        writeln( "    --read-png <image path> <pixel size>" );
        writeln( "    --binarize <minimum luminance>" );
        writeln( "    --invert" );
        writeln( "    --vectorize <drawing color> <maximum color distance> <polygon height>" );
        writeln( "    --write-svg <drawing path>" );
        writeln( "    --write-obj <mesh path>" );
        writeln( "Examples :" );
        writeln( "    rez --load input.png --pixelize 1 1 128 0.98 pixel_mask.png --save output.png" );

        Abort( "Invalid arguments : " ~ argument_array.to!string() );
    }
}
