extends CharacterBody2D

#i knda need those
@export var max_jump_force : float = 50.0
@export var jump_force_inc_rate : float = 1.0
var jump_current_force : float = 0.0
var min_vector : Vector2 = Vector2(-1,-1)
var max_vector : Vector2 = Vector2(1,1)
var can_grab_wall : bool = true
var can_grab_item : bool = false
var can_interact_with_exit: bool = false
var item_to_grab : Node2D
var hold_range : float = 50.0
var grabbed_the_wall : bool = false
@export var hit_force : float = 50.0
var grawitacja_on : bool = false
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var walls_grabbed : int = 0


@export var max_oxygen : float = 100.0
@onready var current_oxygen : float = max_oxygen
@export var oxygen_UI : Label


func _ready():
	pass

#increasing the jump force
func add_jump_force(amount):
	if jump_current_force <= max_jump_force:
		jump_current_force = jump_current_force + amount

#just follow the mouse position for now
func grab_item(item):
	item.freeze = true
	item.freeze = false
	item.global_position = global_position + get_local_mouse_position().normalized()*50

#release with force if mouse is outside, release calm if mouse is close
func release_item(item):
	if get_local_mouse_position() > Vector2(50,50) or get_local_mouse_position() < Vector2(-50,-50):
		item.apply_force(get_local_mouse_position().normalized()*100)
	else:
		item.apply_force(get_local_mouse_position().normalized()*0.5)
		
func _physics_process(delta):
	oxygen_UI.text = str("Oxygen Level: ", current_oxygen)
	if current_oxygen <= 0:
		get_tree().reload_current_scene()

func _process(delta):
	if grawitacja_on == true:
		if not is_on_floor():
			velocity.y += gravity * delta
	#keep adding force while spacebar is held
	if Input.is_action_pressed("jump") and grabbed_the_wall == true:
		add_jump_force(jump_force_inc_rate)
		print(jump_current_force)
	#release the force on release
	if Input.is_action_just_released("jump") and grabbed_the_wall == true:
		var target : Vector2 = get_local_mouse_position()
		print("lece do", target.normalized())
		velocity = target.normalized() * jump_current_force
		print("moja premdkosc", velocity) 
		jump_current_force = 0.0
		print("released wall")
		grabbed_the_wall = false
	
	#grab wall once if possible
	if Input.is_action_just_pressed("grab"):
		if can_grab_wall == true and grabbed_the_wall == false:
			velocity = Vector2(0,0)
			grabbed_the_wall = true
			print("puscilem murek", grabbed_the_wall)
			print("grabbed wall")
		print(can_grab_wall)
		
	#restart level
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()
	
	#grab item and hold
	if Input.is_action_pressed("grab"):
		if can_grab_item == true:
			grab_item(item_to_grab)
			
	#release the grab
	if Input.is_action_just_released("grab"):
		if can_grab_item == true:
			release_item(item_to_grab)
	
	#interact
	if Input.is_action_just_pressed("interact"):
		if can_interact_with_exit == true:
			pass
	
	#push rigidbodies
	if move_and_slide(): # true if collided
		for i in get_slide_collision_count():
			var col = get_slide_collision(i)
			if col.get_collider() is RigidBody2D:
				col.get_collider().apply_force(col.get_normal() * -hit_force)
	
	#bounce off the walls
	var collision = move_and_collide(velocity * delta)
	if collision && grawitacja_on == false:
		velocity = velocity.bounce(collision.get_normal())
		if collision.get_collider().has_method("hit"):
			collision.get_collider().hit()
			
	
	#honestly no idea
	move_and_slide()

#check what entered the mouth
func _on_player_grab_area_area_entered(area):
	if area.is_in_group("SafeWall"):
		walls_grabbed = walls_grabbed + 1
		if walls_grabbed >= 1:
			can_grab_wall = true
			print("touched a wall")
	if area.is_in_group("Item"):
		can_grab_item = true
		item_to_grab = area.get_parent()
		print("touched an item")
	if area.is_in_group("Exit"):
		can_interact_with_exit = true
		print("touched the exit")
	if area.is_in_group("Grass"):
		print("touched grass")
	if area.is_in_group("GravityZone"):
		grawitacja_on = true
	if area.is_in_group("OxygenBoost"):
		current_oxygen = max_oxygen

#check what exited the mouth
func _on_player_grab_area_area_exited(area):
	if area.is_in_group("SafeWall"):
		walls_grabbed = walls_grabbed - 1
		if walls_grabbed == 0:
			can_grab_wall = false
			grabbed_the_wall = false
	if area.is_in_group("Item"):
		can_grab_item = false
	if area.is_in_group("Exit"):
		can_interact_with_exit = false


func _on_oxygen_tick_timer_timeout():
	current_oxygen = current_oxygen - 1.0
