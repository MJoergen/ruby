#ifndef _GEOM_H_
#define _GEOM_H_

// Returns 1 if the point (point_x, point_y)
// lies within the rectangle with the corners
// (min_x, min_y, max_x, max_y)
// Return 0 otherwise
// This function requires that
// min_x < max_x and min_y < max_y
// Same as above, but expects floats as arguments.
int point_in_rectangle(float point_x, float point_y,
        float min_x, float min_y, float max_x, float max_y);

// Returns same sign as (x1-x2) if the point (px, py)
// lies above the line through (x1, y1) and (x2, y2)
// Returns zero if the point lies on the line.
// Returns same sign as (x2-x1) if the point lies below the line.
float point_side_of_line(float px, float py,
        float x1, float y1, float x2, float y2);

// Returns nonzero, if the line segment connecting (x1, y1) with (x2, y2)
// collides with the rectangle between (bx, by) and (bx+width, by+height)
// Returns zero otherwise
int collision_line_segment_box(float x1, float y1, float x2, float y2,
        float bx, float by, float width, float height);

// Returns nonzero if the point (px, py) is within the distance radius
// to the line segment connecting (x1, y1) and (x2, y2)
// Returns zero otherwise
int collision_radius_to_line_segment(float x1, float y1, float x2, float y2,
        float px, float py, float radius);
    
// Returns nonzero if disc passing from (x1, y1) to (x2, y2) intersects with a 
// rectangle with corners at (bx, by) and (bx+width, by+height).
// Returns zero otherwise
int collision_box_line_with_radius(float bx, float by, float width, float height,
        float x1, float y1, float x2, float y2, float radius);

float dist2(float x1, float y1, float x2, float y2);

int collision_circle_box(float cx, float cy, float radius, float bx, float by, float width, float height);

#endif // _GEOM_H_

