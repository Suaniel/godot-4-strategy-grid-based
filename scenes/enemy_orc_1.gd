extends Area2D

var tile_size: int = 16
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position = position.snapped(Vector2.ONE * tile_size) #snap rounds the result to nearest tile increment
	position += Vector2.ONE * tile_size/2
#snap rounds the result to nearest tile increment

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
