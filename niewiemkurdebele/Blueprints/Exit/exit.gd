extends Area2D

var exit_open : bool = false
@export var is_gravity_fix : bool = false
var is_gravity_fixed : bool = false
@export var is_sluza : bool = false
@onready var murek : StaticBody2D = get_node("Wall")
var gdziejestmurek : Transform2D
# Called when the node enters the scene tree for the first time.
func _ready():
	gdziejestmurek = murek.get_global_transform()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_area_entered(area):
	if area.is_in_group("Item"):
		if exit_open == false:
			$ExitIcon.modulate = Color(0,1,0,0.695)
			remove_child($Wall)
			exit_open = true
		if is_sluza == true:
			$Timer.start()
		if is_gravity_fix == true and is_gravity_fixed == false:
			fix_the_fucking_gravity()
			

func _on_timer_timeout():
	add_child(murek) 
	murek.set_global_transform(gdziejestmurek)
	$ExitIcon.modulate = Color(1,0,0,0.695)
	$Timer.set_wait_time(5)
	print($Timer.get_wait_time())
	
	
func fix_the_fucking_gravity():
	get_parent().get_node("GravityZone").queue_free()
