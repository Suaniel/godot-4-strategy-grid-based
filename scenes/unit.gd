# Represents a unit on the game board.
# The board manages the Unit's position inside the game grid.

@tool
class_name Unit
extends Path2D

# Emitted hen te unit reached the end of a path along which it was walking
# We'll use this to notify the game board that a unit has reached its destination 
#	and can let the player select another unit
signal walk_finished

@export var grid: Resource = preload("res://Grid.tres")
#Distance to which the unit can walk in cells.
@export var move_range: int = 6
# Texture representing the unit
# With the tool mode, assigning a new texdture to this property in the inspector will update
#	the unit's sprite instantly
@export var skin: Texture: set = set_skin
# Our unit's skin is just a sprite and, depending on its size, an offset will need to be added for the
#	shadow  to allign with the unit's model
@export var skin_offset := Vector2.ZERO: set = set_skin_offset
# The unit's move speed in pixels
@export var move_speed := 16

# Coorindates of the grid's cell the unit is on
var cell := Vector2.ZERO: set = set_cell
# Toggle's "selected" animation on the unit
var is_selected := false: set = set_is_selected
# Through its setter function, the "_is_walking" property toggles processing for this unit.
var _is_walking := false: set = _set_is_walking

@onready var _sprite: Sprite2D = $PathFollow2D/UnitSprite
@onready var _anim_player: AnimationPlayer = $AnimationPlayer
@onready var _path_follow: PathFollow2D = $PathFollow2D

# When changing the cell's value, we dont want to allow coordinates outside of the grid, so we clamp them
func set_cell(value: Vector2) -> void:
	cell = grid.clamp(value)

# The "is_selected" property toggles playback of the "selected" animation
func set_is_selected(value: bool) -> void:
	is_selected = value
	if is_selected:
		_anim_player.play("selected")
	else:
		_anim_player.play("idle")

# Both setters below manipulate the unit's Sprite node
# Here, the sprite's texture is updated
func set_skin(value: Texture) -> void:
	skin = value
	# Setter functions are called during the node's "_init()" callback, before they entered the
	#	tree. At that point in time, the "_sprite" variable is "null". If so, we have to wait to
	#	udpate the sprite's properties.
	if not _sprite:
		# the await owner.ready allows us to wait until the node's "_ready()" callback ended.
		await self.ready
	_sprite.texture = value

func set_skin_offset(value: Vector2) -> void:
	skin_offset = value
	if not _sprite:
		await self.ready
	_sprite.position = value

func _set_is_walking(value: bool) -> void:
	_is_walking = value
	set_process(_is_walking)
	
func _ready() -> void:
	# We'll use the "_process()" callback to move the unit along a path. Unless it has a path to walk,
	#	we don't want it to update every frame.
	set_process(false)
	
	# The following lines initialize the "cell" property and snap the unit to the cell's center
	#	on the map.
	self.cell = grid.calculate_grid_coordinates(position)
	position = grid.calculate_map_position(cell)
	
	if not Engine.is_editor_hint(): #check if it replaces the Engine.editor_hint() function from Godot 3
		# We create the curve resource here because creating it in the editor prevents us from
		#	moving the unit.
		curve = Curve2D.new()
	var points := [ 
		Vector2(2, 2),
		Vector2(2, 5),
		Vector2(5, 3),
		]
		
	walk_along(PackedVector2Array(points))

func _process(delta: float) -> void:
	# Every frame, the "PathFollow2D.offset" property moves the sprite along the "curve"
	# The great thing about this is it moves an exact number of pixels taking turns into account.
	_path_follow.h_offset += move_speed * delta
	_path_follow.v_offset += move_speed * delta
	
	# When we increase the "offset" above, the "unit_offset" also updates. It represents how far you
	#	are along the "curve" in percent. Where a value of "1.0" means you reached the end.
	# When that is the case, the unit is done moving
	if _path_follow.h_offset >= 1.0 and _path_follow.v_offset >= 1.0:
		# Setting "is_walking" to "false" also turns off processing
		self._is_walking = false
		# Bellow, we reset the offset to "0.0", which snaps the sprites back to the Unit node's
		# position, we position the node to the center of the target grid cell, and we clear the curve
		# In the process loop, we only moved the sprite, and not the unit itself. The following lines
		#	move the unit in a way that's transparent to the player.
		_path_follow.h_offset = 0.0
		_path_follow.v_offset = 0.0
		position = grid.calculate_map_position(cell)
		curve.clear_points()
		# Finally, we emit a signal. We'll use this one with the game board
		emit_signal("walk_finished")

# Starts walking along the "path"
# "path" is an array of grid cooridnates that the function converts to map coordinates.
func walk_along(path: PackedVector2Array) -> void:
	if path.is_empty():
		return
		
	# This code converts the "path" to points on the "curve". The property comes from "Path2D"
	#	class the unit extends
	curve.add_point(Vector2.ZERO)
	for point in path:
		curve.add_point(grid.calculate_map_position(point) - position)
	# We instantly change the unit's cell to the target position. You could also do that when it
	#	reaches the end of the path, using "grid.calculate_grid_coordinates()", instead.
	# Its done this way because we have the coordinates provided by the "path" argument.
	# The cell itself represents the grid coordinates the unit will stand on.
	cell = path[-1]
	# The "_is_walking" property triggers the move animation and turns on "_proces()".
	self._is_walking = true
