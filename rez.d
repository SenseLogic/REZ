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
import std.math : abs, floor, ceil, cos, sin, sqrt, PI;
import std.stdio : writeln, File;
import std.string : endsWith, format, indexOf, join, split, startsWith;

// -- TYPES

struct VECTOR_2
{
    // -- ATTRIBUTES

    double
        X = 0.0,
        Y = 0.0;

    // -- INQUIRIES

    double GetDistance(
        VECTOR_2 vector
        )
    {
        double
            x_distance,
            y_distance;

        x_distance = vector.X - X;
        y_distance = vector.Y - Y;

        return sqrt( x_distance * x_distance + y_distance * y_distance );
    }

    // -- OPERATIONS

    void SetInterpolatedVector(
        ref VECTOR_2 first_vector,
        ref VECTOR_2 second_vector,
        double interpolation_factor
        )
    {
        X = first_vector.X + ( second_vector.X - first_vector.X ) * interpolation_factor;
        Y = first_vector.Y + ( second_vector.Y - first_vector.Y ) * interpolation_factor;
    }

    // ~~

    void ExtendInterval(
        ref VECTOR_2 minimum_vector,
        ref VECTOR_2 maximum_vector
        )
    {
        if ( X < minimum_vector.X )
        {
            minimum_vector.X = X;
        }

        if ( X > maximum_vector.X )
        {
            maximum_vector.X = X;
        }

        if ( Y < minimum_vector.Y )
        {
            minimum_vector.Y = Y;
        }

        if ( Y > maximum_vector.Y )
        {
            maximum_vector.Y = Y;
        }
    }

    // ~~

    void Rotate(
        double angle
        )
    {
        double
            angle_cosinus,
            angle_sinus,
            old_x;

        angle_cosinus = angle.cos();
        angle_sinus = angle.sin();

        old_x = X;
        X = X * angle_cosinus - Y * angle_sinus;
        Y = old_x * angle_sinus + Y * angle_cosinus;
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

    string GetHexadecimalText(
        )
    {
        return
            Red.GetHexadecimalText()
            ~ Green.GetHexadecimalText()
            ~ Blue.GetHexadecimalText()
            ~ Alpha.GetHexadecimalText();
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
}

// ~~

struct PIXEL
{
    // -- ATTRIBUTES

    ubyte
        Opacity = 0;

    // -- OPERATIONS

    void SetOpacity(
        long opacity
        )
    {
        Opacity = cast( ubyte )opacity;
    }

    // ~~

    void SetFromColor(
        ubyte color_red,
        ubyte color_green,
        ubyte color_blue,
        ubyte color_alpha,
        long minimum_luminance,
        long maximum_luminance,
        long first_luminance,
        long last_luminance
        )
    {
        long
            luminance;

        luminance
            = ( cast( long )color_red * 77
                + cast( long )color_green * 151
                + cast( long )color_blue * 28 ) >> 8;

        if ( luminance < minimum_luminance )
        {
            luminance = minimum_luminance;
        }
        else if ( luminance > maximum_luminance )
        {
            luminance = maximum_luminance;
        }

        luminance
            = first_luminance
              + ( luminance - minimum_luminance )
                * ( last_luminance - first_luminance )
                / ( maximum_luminance - minimum_luminance );

        if ( luminance < 0 )
        {
            luminance = 0;
        }
        else if ( luminance > 255 )
        {
            luminance = 255;
        }

        SetOpacity( ( luminance * color_alpha ) / 255 );
    }

    // ~~

    void Trace(
        PIXEL pixel
        )
    {
        if ( Opacity < pixel.Opacity )
        {
            Opacity = pixel.Opacity;
        }
    }
}

// ~~

class IMAGE
{
    // -- ATTRIBUTES

    long
        ColumnCount,
        LineCount;
    PIXEL[]
        PixelArray;
    long
        MaximumBadPixelCount;

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
        long minimum_opacity
        )
    {
        return
            column_index >= 0
            && column_index < ColumnCount
            && line_index >= 0
            && line_index < LineCount
            && PixelArray[ line_index * ColumnCount + column_index ].Opacity >= minimum_opacity;
    }

    // ~~

    long GetOpacity(
        long column_index,
        long line_index
        )
    {
        if ( column_index >= 0
             && column_index < ColumnCount
             && line_index >= 0
             && line_index < LineCount )
        {
            return PixelArray[ GetPixelIndex( column_index, line_index ) ].Opacity;
        }
        else
        {
            return 0;
        }
    }

    // ~~

    void WritePngFile(
        string file_path,
        string pixel_color_text = "255.255.255"
        )
    {
        long
            column_index,
            line_index;
        Color
            color;
        TrueColorImage
            true_color_image;
        COLOR
            pixel_color;
        PIXEL
            pixel;

        writeln( "Saving image : ", file_path );
        writeln( "    Line count : ", LineCount );
        writeln( "    Column count : ", ColumnCount );
        writeln( "    Pixel color : ", pixel_color_text );

        pixel_color.SetFromText( pixel_color_text );

        true_color_image = new TrueColorImage( cast( int )ColumnCount, cast( int )LineCount );

        for ( line_index = 0;
              line_index < LineCount;
              ++line_index )
        {
            for ( column_index = 0;
                  column_index < ColumnCount;
                  ++column_index )
            {
                color.r = pixel_color.Red;
                color.g = pixel_color.Green;
                color.b = pixel_color.Blue;
                color.a = GetPixel( column_index, line_index ).Opacity;

                true_color_image.setPixel( cast( int )column_index, cast( int )line_index, color );
            }
        }

        writePng( file_path, true_color_image );
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

    void TracePixel(
        long column_index,
        long line_index,
        PIXEL pixel
        )
    {
        PixelArray[ GetPixelIndex( column_index, line_index ) ].Trace( pixel );
    }

    // ~~

    void ReadPngFile(
        string file_path,
        long minimum_luminance = 0,
        long maximum_luminance = 255,
        long first_luminance = 0,
        long last_luminance = 255
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

        true_color_image = readPng( file_path ).getAsTrueColorImage();

        LineCount = true_color_image.height();
        ColumnCount = true_color_image.width();
        PixelArray.length = LineCount * ColumnCount;

        writeln( "    Line count : ", LineCount );
        writeln( "    Column count : ", ColumnCount );
        writeln( "    Minimum luminance : ", minimum_luminance );
        writeln( "    Maximum luminance : ", maximum_luminance );
        writeln( "    First luminance : ", first_luminance );
        writeln( "    Last luminance : ", last_luminance );

        for ( line_index = 0;
              line_index < LineCount;
              ++line_index )
        {
            for ( column_index = 0;
                  column_index < ColumnCount;
                  ++column_index )
            {
                color = true_color_image.getPixel( cast( int )column_index, cast( int )line_index );

                pixel.SetFromColor( color.r, color.g, color.b, color.a, minimum_luminance, maximum_luminance, first_luminance, last_luminance );
                SetPixel( column_index, line_index, pixel );
            }
        }
    }

    // ~~

    void Resize(
        long column_count,
        long line_count
        )
    {
        ColumnCount = column_count;
        LineCount = line_count;
        PixelArray.length = column_count * line_count;
    }

    // ~~

    void Resize(
        IMAGE image
        )
    {
        Resize( image.ColumnCount, image.LineCount );
    }

    // ~~

    void Copy(
        IMAGE image
        )
    {
        Resize( image );

        foreach ( pixel_index, ref pixel; PixelArray )
        {
            pixel = image.PixelArray[ pixel_index ];
        }
    }

    // ~~

    void Fill(
        )
    {
        foreach ( ref pixel; PixelArray )
        {
            pixel.Opacity = 255;
        }
    }

    // ~~

    void MakeStampImage(
        IMAGE image,
        long rotation_index,
        long rotation_count
        )
    {
        long
            column_index,
            line_index,
            opacity,
            sub_pixel_column_index,
            sub_pixel_line_index;
        double
            rotation_angle,
            rotation_step;
        VECTOR_2
            center_position_vector,
            half_size_vector,
            maximum_position_vector,
            minimum_position_vector,
            position_vector;

        if ( image.LineCount == image.ColumnCount )
        {
            rotation_count *= 2;
        }

        rotation_step = PI / rotation_count;
        rotation_angle = rotation_step * rotation_index;

        half_size_vector.X = image.ColumnCount * 0.5;
        half_size_vector.Y = image.LineCount * 0.5;

        position_vector.X = half_size_vector.X - 0.1;
        position_vector.Y = half_size_vector.Y - 0.1;
        position_vector.Rotate( rotation_angle );
        position_vector.ExtendInterval( minimum_position_vector, maximum_position_vector );

        position_vector.X = -half_size_vector.X + 0.1;
        position_vector.Y = half_size_vector.Y - 0.1;
        position_vector.Rotate( rotation_angle );
        position_vector.ExtendInterval( minimum_position_vector, maximum_position_vector );

        position_vector.X = half_size_vector.X - 0.1;
        position_vector.Y = -half_size_vector.Y + 0.1;
        position_vector.Rotate( rotation_angle );
        position_vector.ExtendInterval( minimum_position_vector, maximum_position_vector );

        position_vector.X = -half_size_vector.X + 0.1;
        position_vector.Y = -half_size_vector.Y + 0.1;
        position_vector.Rotate( rotation_angle );
        position_vector.ExtendInterval( minimum_position_vector, maximum_position_vector );

        Resize(
            ( maximum_position_vector.X.floor() - minimum_position_vector.X.floor() ).to!long() + 1,
            ( maximum_position_vector.Y.floor() - minimum_position_vector.Y.floor() ).to!long() + 1
            );

        center_position_vector.X = ColumnCount * 0.5;
        center_position_vector.Y = LineCount * 0.5;

        for ( line_index = 0;
              line_index < LineCount;
              ++line_index )
        {
            for ( column_index = 0;
                  column_index < ColumnCount;
                  ++column_index )
            {
                opacity = 0;

                for ( sub_pixel_line_index = 0;
                      sub_pixel_line_index < 4;
                      ++sub_pixel_line_index )
                {
                    for ( sub_pixel_column_index = 0;
                          sub_pixel_column_index < 4;
                          ++sub_pixel_column_index )
                    {
                        position_vector.X
                            = column_index + sub_pixel_column_index * 0.25 + 0.125
                              - center_position_vector.X;

                        position_vector.Y
                            = line_index + sub_pixel_line_index * 0.25 + 0.125
                              - center_position_vector.Y;

                        position_vector.Rotate( -rotation_angle );

                        if ( position_vector.X >= -half_size_vector.X
                             && position_vector.X <= half_size_vector.X
                             && position_vector.Y >= -half_size_vector.Y
                             && position_vector.Y <= half_size_vector.Y )
                        {
                            opacity
                                += image.GetOpacity(
                                       ( position_vector.X + half_size_vector.X ).floor().to!long(),
                                       ( position_vector.Y + half_size_vector.Y ).floor().to!long()
                                       );
                        }
                    }
                }

                PixelArray[ GetPixelIndex( column_index, line_index ) ].SetOpacity( opacity / 16 );
            }
        }

        if ( false )
        {
            WritePngFile(
                "stamp_"
                ~ image.ColumnCount.to!string()
                ~ "_"
                ~ image.LineCount.to!string()
                ~ "_"
                ~ rotation_index.to!string()
                ~ "_"
                ~ rotation_count.to!string()
                ~ ".png"
                );
        }
    }

    // ~~

    void AddStampImages(
        ref IMAGE[] stamp_image_array,
        string text
        )
    {
        long
            column_count,
            line_count,
            maximum_bad_pixel_count,
            rotation_count,
            rotation_index;
        string[]
            part_array;
        IMAGE
            stamp_image,
            rotated_stamp_image;

        writeln( "Adding stamp : ", text );

        part_array = text.split( '@' );
        text = part_array[ 0 ];

        part_array = part_array[ 1 ].split( ':' );
        maximum_bad_pixel_count = part_array[ 0 ].to!long();
        rotation_count = part_array[ 1 ].to!long();

        stamp_image = new IMAGE();

        if ( text.endsWith( ".png" ) )
        {
            stamp_image.ReadPngFile( text );
        }
        else
        {
            part_array = text.split( '.' );
            column_count = part_array[ 0 ].to!long();
            line_count = part_array[ 1 ].to!long();

            stamp_image.Resize( column_count, line_count );
            stamp_image.Fill();
        }

        stamp_image.MaximumBadPixelCount = maximum_bad_pixel_count;
        stamp_image_array ~= stamp_image;

        for ( rotation_index = 1;
              rotation_index < rotation_count;
              ++rotation_index )
        {
            rotated_stamp_image = new IMAGE();
            rotated_stamp_image.MakeStampImage( stamp_image, rotation_index, rotation_count );
            rotated_stamp_image.MaximumBadPixelCount = maximum_bad_pixel_count;
            stamp_image_array ~= rotated_stamp_image;
        }
    }

    // ~~

    void Trace(
        long maximum_opacity_distance,
        string[] stamp_definition_array
        )
    {
        long
            bad_pixel_count,
            column_count,
            column_index,
            line_count,
            line_index,
            stamp_column_index,
            stamp_line_index,
            stamp_pixel_count,
            matching_pixel_count;
        IMAGE
            traced_image;
        IMAGE[]
            stamp_image_array;
        PIXEL
            stamp_pixel,
            pixel;

        foreach ( stamp_definition_index, stamp_definition; stamp_definition_array )
        {
            AddStampImages( stamp_image_array, stamp_definition );
        }

        writeln( "Tracing image :" );
        writeln( "    Maximum color distance : ", maximum_opacity_distance );
        writeln( "    Stamp array : ", stamp_definition_array.join( ' ' ) );

        traced_image = new IMAGE();
        traced_image.Resize( this );

        foreach ( stamp_image; stamp_image_array )
        {
            line_count = LineCount - stamp_image.LineCount + 1;
            column_count = ColumnCount - stamp_image.ColumnCount + 1;

            for ( line_index = 0;
                  line_index < line_count;
                  ++line_index )
            {
                for ( column_index = 0;
                      column_index < column_count;
                      ++column_index )
                {
                    stamp_pixel_count = 0;
                    matching_pixel_count = 0;

                    for ( stamp_line_index = 0;
                          stamp_line_index < stamp_image.LineCount;
                          ++stamp_line_index )
                    {
                        for ( stamp_column_index = 0;
                              stamp_column_index < stamp_image.ColumnCount;
                              ++stamp_column_index )
                        {
                            stamp_pixel = stamp_image.GetPixel( stamp_column_index, stamp_line_index );

                            if ( stamp_pixel.Opacity > 0 )
                            {
                                ++stamp_pixel_count;

                                pixel = GetPixel( column_index + stamp_column_index, line_index + stamp_line_index );

                                if ( pixel.Opacity > 0
                                     && pixel.Opacity + maximum_opacity_distance >= stamp_pixel.Opacity )
                                {
                                    ++matching_pixel_count;
                                }
                            }
                        }
                    }

                    bad_pixel_count = stamp_pixel_count - matching_pixel_count;

                    if ( bad_pixel_count <= stamp_image.MaximumBadPixelCount )
                    {
                        for ( stamp_line_index = 0;
                              stamp_line_index < stamp_image.LineCount;
                              ++stamp_line_index )
                        {
                            for ( stamp_column_index = 0;
                                  stamp_column_index < stamp_image.ColumnCount;
                                  ++stamp_column_index )
                            {
                                stamp_pixel = stamp_image.GetPixel( stamp_column_index, stamp_line_index );

                                traced_image.TracePixel(
                                    column_index + stamp_column_index,
                                    line_index + stamp_line_index,
                                    stamp_pixel
                                    );
                            }
                        }
                    }
                }
            }
        }

        Copy( traced_image );
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

    // ~~

    void Simplify(
        double maximum_distance
        )
    {
        double
            position_distance;
        long
            edge_index,
            next_edge_index,
            prior_edge_index;
        VECTOR_2
            next_position_vector,
            position_vector,
            prior_position_vector;

        for ( edge_index = 0;
              edge_index < EdgeArray.length
              && EdgeArray.length >= 3;
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

            prior_position_vector = EdgeArray[ prior_edge_index ].PositionVector;
            next_position_vector = EdgeArray[ next_edge_index ].PositionVector;
            position_vector = EdgeArray[ edge_index ].PositionVector;

            position_distance
                = position_vector.GetDistance( prior_position_vector )
                  + position_vector.GetDistance( next_position_vector )
                  - prior_position_vector.GetDistance( next_position_vector );

            if ( position_distance >= -maximum_distance
                 && position_distance <= maximum_distance )
            {
                EdgeArray = EdgeArray[ 0 .. edge_index ] ~ EdgeArray[ edge_index + 1 .. $ ];

                --edge_index;
            }
        }
    }
}

// ~~

class DRAWING
{
    // -- ATTRIBUTES

    long
        ColumnCount,
        LineCount;
    POINT[]
        PointArray;
    POLYGON[]
        PolygonArray;

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
        double pixel_size,
        double height
        )
    {
        VECTOR_3
            position_vector;

        position_vector.X = ( edge.PositionVector.X - ( ColumnCount - 1 ).to!double() * 0.5 ) * pixel_size;
        position_vector.Y = -( edge.PositionVector.Y - ( LineCount - 1 ).to!double() * 0.5 ) * pixel_size;
        position_vector.Z = height;

        return position_vector;
    }

    // ~~

    void WriteSvgFile(
        string file_path,
        double line_width,
        string line_color_text
        )
    {
        long
            edge_index;
        File
            file;
        COLOR
            line_color;
        EDGE
            edge;

        writeln( "Writing drawing : ", file_path );
        writeln( "    Line width : ", line_width );
        writeln( "    Line color : ", line_color_text );

        line_color.SetFromText( line_color_text );

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
                    " Z\" stroke=\"#"
                    ~ line_color.GetHexadecimalText()
                    ~ "\" stroke-width=\""
                    ~ line_width.GetText()
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
        long minimum_opacity
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
                    = image.HasPixel( column_index, line_index, minimum_opacity );
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
        long direction,
        double maximum_distance
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

        if ( maximum_distance > 0.0 )
        {
            polygon.Simplify( maximum_distance );
        }

        PolygonArray ~= polygon;
    }

    // ~~

    void SetFromImage(
        IMAGE image,
        long minimum_opacity,
        double maximum_distance
        )
    {
        long
            column_index,
            direction,
            line_index,
            point_index;

        writeln( "Vectorizing image" );
        writeln( "    Minimum opacity : ", minimum_opacity );
        writeln( "    Maximum distance : ", maximum_distance );

        SetPoints( image, minimum_opacity );

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
                        AddPolygon( column_index, line_index, direction, maximum_distance );
                    }
                }
            }
        }
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
        DRAWING drawing,
        double pixel_size,
        double edge_height
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

                AddPositionVector( drawing.GetPositionVector( polygon.EdgeArray[ second_edge_index ], pixel_size, 0.0 ) );
                AddPositionVector( drawing.GetPositionVector( polygon.EdgeArray[ first_edge_index ], pixel_size, 0.0 ) );
                AddPositionVector( drawing.GetPositionVector( polygon.EdgeArray[ first_edge_index ], pixel_size, edge_height ) );
                AddPositionVector( drawing.GetPositionVector( polygon.EdgeArray[ second_edge_index ], pixel_size, edge_height) );

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

string GetHexadecimalText(
    ubyte natural
    )
{
    return
        ""
        ~ "0123456789ABCDEF"[ natural >> 4 ]
        ~ "0123456789ABCDEF"[ natural & 15 ];
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
             && argument_count >= 1
             && argument_count <= 5 )
        {
            image = new IMAGE();
            image.ReadPngFile(
                argument_array[ 0 ],
                ( argument_count > 1 ) ? argument_array[ 1 ].to!long() : 0,
                ( argument_count > 2 ) ? argument_array[ 2 ].to!long() : 255,
                ( argument_count > 3 ) ? argument_array[ 3 ].to!long() : 0,
                ( argument_count > 4 ) ? argument_array[ 4 ].to!long() : 255
                );
        }
        else if ( option == "--trace"
                  && argument_count >= 2 )
        {
            image.Trace(
                argument_array[ 0 ].to!long(),
                argument_array[ 1 .. argument_count ]
                );
        }
        else if ( option == "--vectorize"
                  && argument_count == 2
                  && image !is null )
        {
            drawing = new DRAWING();
            drawing.SetFromImage(
                image,
                argument_array[ 0 ].to!long(),
                argument_array[ 1 ].to!double()
                );
        }
        else if ( option == "--write-png"
                  && argument_count >= 1
                  && argument_count <= 2 )
        {
            image.WritePngFile(
                argument_array[ 0 ],
                ( argument_count > 1 ) ? argument_array[ 1 ] : "255.255.255.255"
                );
        }
        else if ( option == "--write-svg"
                  && argument_count >= 1
                  && argument_count <= 3
                  && drawing !is null )
        {
            drawing.WriteSvgFile(
                argument_array[ 0 ],
                ( argument_count > 1 ) ? argument_array[ 1 ].to!double() : 1.0,
                ( argument_count > 2 ) ? argument_array[ 2 ] : "0.0.0.255"
                );
        }
        else if ( option == "--write-obj"
                  && argument_count >= 1
                  && argument_count <= 3
                  && drawing !is null )
        {
            mesh = new MESH();
            mesh.SetFromDrawing(
                drawing,
                ( argument_count > 1 ) ? argument_array[ 1 ].to!double() : 0.01,
                ( argument_count > 2 ) ? argument_array[ 2 ].to!double() : 2.5
                );
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
        writeln( "    --read-png <image path> [minimum luminance] [maximum luminance] [first luminance] [last luminance]" );
        writeln( "    --trace <maximum opacity distance> <stamp definition> ..." );
        writeln( "    --vectorize <minimum luminance> <maximum position distance>" );
        writeln( "    --write-png <image path> [pixel color]" );
        writeln( "    --write-svg <drawing path> [line width] [line color]" );
        writeln( "    --write-obj <mesh path> [pixel size] [edge height]" );
        writeln( "Examples :" );
        writeln( "    rez --read-png test.png 64 255 255 0 --trace 128 4.12@3:2 --write-png OUT/test.png" );
        writeln( "    rez --read-png test.png --vectorize 128 0.5 --write-svg OUT/test.svg 1 --write-obj OUT/test.obj 0.01 2.5" );

        Abort( "Invalid arguments : " ~ argument_array.to!string() );
    }
}
