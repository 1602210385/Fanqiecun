extends CharacterBody2D

enum State {
	idle,
	run,
	jump,
	fall,
	land,
	atk,
	double_jump,
}
const ground_state := [State.idle , State.run]
const air_state := [State.jump]

const X_speed := 200
const jump_velocity := -400

var gravity :=ProjectSettings.get("physics/2d/default_gravity") as float
var double_jump := true

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer


var bullet: PackedScene


func tick_physics(current_state :State, delta) :
	match  current_state:
		State.idle:
			move(delta)
			
		State.run:
			move(delta)
			
		State.jump:
			move(delta)
				
		State.atk:
			pass
			
		State.fall:
			move(delta)

		State.land:
			move(delta)
			
		State.double_jump:
			move(delta)

func move(delta):
	var direction := Input.get_axis("move_left", "move_right")
	velocity.x = direction * X_speed
	velocity.y += gravity * delta
	
	if not is_zero_approx(direction):
		sprite_2d.flip_h = direction < 0

	move_and_slide()
			
func atk():
	bullet = load("res://bullet.tscn")
	var new_bullet : bullet = bullet.instantiate()
	var x := -1 if sprite_2d.flip_h else  1
	new_bullet.speed = Vector2(500 * x, 0)
	$"/root/".add_child(new_bullet)
	new_bullet.global_position = global_position + Vector2(-80, -70)
	
func renew_state(current_state: State) -> State:
	var direction := Input.get_axis("move_left", "move_right")
	
	match current_state	:
		State.idle:
			if not is_zero_approx(direction) and not is_zero_approx(velocity.x):
				return State.run
			if Input.is_action_just_pressed("jump"):
				return State.jump
			if Input.is_action_just_pressed("attack"):
				return State.atk
			if not is_on_floor():
				return State.fall
				
		State.run:
			if is_zero_approx(velocity.x):
				return State.idle
			if Input.is_action_just_pressed("jump"):
				return State.jump
			if Input.is_action_just_pressed("attack"):
				return State.atk	
			if not is_on_floor():
				return State.fall	
				
		State.jump:
			print(current_state)
			if velocity.y >= 0:
				return State.fall
			if not is_on_floor():
				if Input.is_action_just_pressed("jump") and double_jump:
					return State.double_jump
				
		State.fall:
			if is_on_floor():
				double_jump = true
				if not is_zero_approx(velocity.x):
					return State.run
				else :
					return State.land
			if not is_on_floor():
				if Input.is_action_just_pressed("jump") and double_jump:
					return State.double_jump
					
		State.land:
			if Input.is_action_just_pressed("jump"):
				return State.jump
			if Input.is_action_just_pressed("attack"):
				return State.atk	
			if not animation_player.is_playing():
				return State.idle
				
		State.atk:
			if not animation_player.is_playing():
				return State.idle
		
		State.double_jump:
			double_jump = false
			if velocity.y > 0:
				return State.fall
			
			
	return current_state

func transition_state(from: State , to: State) -> void:
	match  to:
		State.idle:
			animation_player.play("idle")

		State.run:
			animation_player.play("move")
			
		State.jump:
			animation_player.play("jump")
			velocity.y = jump_velocity
				
		State.atk:
			animation_player.play("atk")
			atk()
		State.fall:
			animation_player.play("fall")

		State.land:
			animation_player.play("land")
			
		State.double_jump:
			animation_player.play("double_jump")
			velocity.y = jump_velocity
			

