#include <math.h>
#include "geom.h"

// Returns nonzero if the point (point_x, point_y)
// lies within the rectangle with the corners
// (min_x, min_y, max_x, max_y)
// Return zero otherwise
// Requires that min_x <= max_x and min_y <= max_y
int point_in_rectangle(float point_x, float point_y,
        float min_x, float min_y, float max_x, float max_y)
{
    return (min_x   <= point_x &&
            point_x <= max_x   &&
            min_y   <= point_y &&
            point_y <= max_y   );
} // end of point_in_rectangle_f

// Returns nonzero if the point (point_x, point_y)
// lies within the rectangle with the corners
// (x1, y1, x2, y2)
// Return zero otherwise
int point_in_rectangle_full(float point_x, float point_y,
        float x1, float y1, float x2, float y2)
{
	if (x1 < x2)
	{
		if (point_x < x1 || point_x > x2)
			return 0;
	}
	else
	{
		if (point_x < x2 || point_x > x1)
			return 0;
	}

	if (y1 < y2)
	{
		if (point_y < y1 || point_y > y2)
			return 0;
	}
	else
	{
		if (point_y < y2 || point_y > y1)
			return 0;
	}
	
	return 1;
} // end of point_in_rectangle_full

// Returns sign(x1-x2) if the point (px, py)
// lies above the line through (x1, y1) and (x2, y2)
// Returns zero if the point lies on the line.
// Returns sign(x2-x1) if the point lies below the line.
float point_side_of_line(float px, float py,
        float x1, float y1, float x2, float y2)
{
    return (y2-y1)*px + (x1-x2)*py + (x2*y1-x1*y2);
} // end of point_side_of_line

// Returns nonzero, if the line segment connecting (x1, y1) with (x2, y2)
// collides with the rectangle between (bx, by) and (bx+width, by+height)
// Returns zero otherwise
int collision_line_segment_box(float x1, float y1, float x2, float y2,
        float bx, float by, float width, float height)
{
    if (    point_in_rectangle(x1, y1, bx, by, bx + width, by + height) ||
            point_in_rectangle(x2, y2, bx, by, bx + width, by + height))
        return 1;
    else
    {
        if (    (x1 < bx          && x2 < bx)         ||
                (x1 > bx + width  && x2 > bx + width) ||
                (y1 < by          && y2 < by)         ||
                (y1 > by + height && y2 > by + height) )
            return 0;

        if (    point_side_of_line(bx        , by         , x1, y1, x2, y2) < 0 &&
                point_side_of_line(bx + width, by         , x1, y1, x2, y2) < 0 &&
                point_side_of_line(bx + width, by + height, x1, y1, x2, y2) < 0 &&
                point_side_of_line(bx        , by + height, x1, y1, x2, y2) < 0) 
            return 0;

        if (    point_side_of_line(bx        , by         , x1, y1, x2, y2) > 0 &&
                point_side_of_line(bx + width, by         , x1, y1, x2, y2) > 0 &&
                point_side_of_line(bx + width, by + height, x1, y1, x2, y2) > 0 &&
                point_side_of_line(bx        , by + height, x1, y1, x2, y2) > 0)
            return 0;
    }

    return 1;
} // end of collision_line_segment_box

// Returns nonzero if the point (px, py) is within the distance radius
// to the line segment connecting (x1, y1) and (x2, y2)
// Returns zero otherwise
int collision_radius_to_line_segment(float x1, float y1, float x2, float y2,
        float px, float py, float radius)
{
    // This is to increase performance
    if (point_in_rectangle_full(px, py, x1-radius, y1-radius, x2+radius, y2+radius))
    {
        // [dx,dy] is the change from A to B
        float dx = x2-x1;
        float dy = y2-y1;
        float d2 = dx*dx + dy*dy;

        // [ex,ey] is the change from A to P
        float ex = px-x1;
        float ey = py-y1;

        // The projection of the point (px, py) onto the line through 
        // (x1, y1) and (x2, y2) is governed by the parameter scale.
        // If scale is between 0 and 1, then the projection is within
        // the line segment.
        float scale = (dx*ex + dy*ey) / d2;

        float dist2; // Squared distance from point to line segment
        if (scale <= 0.0)
        {
            // Point is closest to (x1, y1)
            dist2 = ex*ex + ey*ey;
        } else if (scale >= 1.0) {
            // Point is closest to (x2, y2)
            float fx = px-x2;
            float fy = py-y2;
            dist2 = fx*fx + fy*fy;
        }
        else
            // Here I'm using the formula in
            // http://en.wikipedia.org/wiki/Distance_from_a_point_to_a_line#Line_defined_by_two_points
        {
            float temp = dy*px-dx*py-x1*y2+x2*y1;
            dist2 = temp*temp / d2;
        }

        return dist2 < radius*radius;
    }

    return 0;
} // end of collision_radius_to_line_segment

// Returns nonzero if disc passing from (x1, y1) to (x2, y2) intersects with a 
// rectangle with corners at (bx, by) and (bx+width, by+height).
// Returns zero otherwise
int collision_box_line_with_radius(float bx, float by, float width, float height,
        float x1, float y1, float x2, float y2, float radius)
{
    return (collision_line_segment_box(x1, y1, x2, y2, bx - radius, by, width + radius*2, height) ||
            collision_line_segment_box(x1, y1, x2, y2, bx, by - radius, width, height + radius*2) ||
            collision_radius_to_line_segment(x1, y1, x2, y2, bx, by, radius) ||
            collision_radius_to_line_segment(x1, y1, x2, y2, bx + width, by, radius) ||
            collision_radius_to_line_segment(x1, y1, x2, y2, bx + width, by + height, radius) ||
            collision_radius_to_line_segment(x1, y1, x2, y2, bx, by + height, radius) );

} // end of collision_box_line_with_radius

// Returns the square of the distance
float dist2(float x1, float y1, float x2, float y2)
{
	float dx = x2-x1;
	float dy = y2-y1;
	return dx*dx + dy*dy;
}

int collision_circle_box(float cx, float cy, float radius, float bx, float by, float width, float height)
{
    if (point_in_rectangle(cx, cy, bx-radius, by-radius, bx+width+radius, by+height+radius)) // optimization
	{
		float radius2 = radius*radius; // The radius squared
		if  (dist2(bx,       by,        cx, cy) < radius2 ||
			 dist2(bx+width, by,        cx, cy) < radius2 ||
			 dist2(bx+width, by+height, cx, cy) < radius2 ||
			 dist2(bx,       by+height, cx, cy) < radius2 ||
			 point_in_rectangle(cx, cy, bx-radius, by, bx+width+radius, by+height) ||
			 point_in_rectangle(cx, cy, bx, by-radius, bx+width, by+height+radius))
			return 1;
	}
	
	return 0;
}
