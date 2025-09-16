# Represents a Grid with its size, the size of each cell in pixels (cell_size), and some helper functions to 
#  calculate and convert coordinates.
# It's meant to be shared between game objects taht need access to those values (class_name makes it a global class)
class_name Grid
extends Resource

# The grid's size in rows and columns.
@export var size := Vector2(11, 6)
# The size of a cell in pixels.
@export var cell_size := Vector2(16, 16)

# Half of cell size. Used to determine the middle point, the position of units in a cell within the grid
var _half_cell_size = cell_size/2.

# Returns the position of a cell's center in pixels.
func calculate_map_position(grid_position: Vector2) -> Vector2:
	return grid_position * cell_size + _half_cell_size
	
# Returns the coordinates of the cell on the grid given a position on the map.
#  complementory to calculate_map_position().
# When Desinging a level, you'll place units visually in the editor. We'll use this function to find
#  the grid coordinates they're placed on, and call calculate_map_position() to snap them to the
#  cells center
func calculate_grid_coordinates(map_position: Vector2) -> Vector2:
	return (map_position / cell_size).floor()
	
# Returns true if the cell_coordinates are within the grid.
# This method and the following one allos us to ensure the cursor or units can never go past the
#  map's limit.
func is_within_bounds(cell_coordinates: Vector2) -> bool:
	var out := cell_coordinates.x >= 0 and cell_coordinates.x < size.x
	var out_y := cell_coordinates.y >= 0 and cell_coordinates.y < size.y
	return (out and out_y)
	
# Makes the grid_position fit within the grid's bounds.
# This is a clamp function designed specifically for our grid coordinates
# The Vector2 class comes with its Vector2.clamp() method, but it doesnt work the same way; it
# limits the vector's length instead of clamping each of teh vector's components individually.
# That's why we need to code a new method:
func clamp(grid_position: Vector2) -> Vector2:
	var out := grid_position
	out.x = clamp(out.x, 0, size.x - 1.0)
	out.y = clamp(out.y, 0, size.y - 1.0)
	return out 
	
# Given Vector2 coordinates, calculates and returns the corresponding integer index. 
# You can use this fucntion to convert 2D coordinates to a 1D array's indices.
#
# There are two cases where you need to convert coordinates like so:
# 1. We'll need it for the AStar algorithm, which requires a unique index for each point on the 
#     graph it uses to find a path.
# 2. You can use it for performance, as one-dimensional arrays are faster to iterate over and to 
#     index than two-dimensional arrays in GDScript
func as_index(cell: Vector2) -> int:
	return int(cell.x + size.x * cell.y)
	
#Code resource link: 
#	https://www.gdquest.com/tutorial/godot/2d/tactical-rpg-movement/lessons/01.grid/
