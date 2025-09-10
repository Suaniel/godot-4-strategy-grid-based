extends CharacterBody2D


@onready var ray = $RayCast2D
var moving: bool = false

var tile_size: int = 16
var inputs := { "right" : Vector2.RIGHT,
				"left"  : Vector2.LEFT,
				"up"    : Vector2.UP,
				"down"  : Vector2.DOWN}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position = position.snapped(Vector2.ONE * tile_size) #snap rounds the result to nearest tile increment
	position += Vector2.ONE * tile_size/2 #Player is centered in the tile
	print('player position', position)


func _input(event: InputEvent):
	if moving:
		return
	for dir in inputs.keys():
		if event.is_action_pressed(dir):
			move(dir)
			print(dir)
			
#func _physics_process(delta: float) -> void:
	#if moving:
		#return
	#for dir in inputs.keys():
		#if Input.is_action_pressed(dir):
			#move(dir)
			#print(dir)


func move(dir):
	ray.target_position = inputs[dir] * tile_size
	ray.force_raycast_update()
	if !ray.is_colliding():
		position += inputs[dir] * tile_size
		print(position)
