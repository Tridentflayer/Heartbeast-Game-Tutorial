extends KinematicBody2D

# Movement variables
var ACCELERATION = 500
var MAX_SPEED = 80
var FRICTION = 500
var velocity = Vector2.ZERO
var roll_vector = Vector2.DOWN
var ROLL_SPEED = 125
var stats = PlayerStats

# State machine setup
enum {
	MOVE, 
	ROLL,
	ATTACK
}
var state = MOVE

# Animation player access
onready var animationPlayer = $PlayerAnimation
onready var animationTree = $PlayerAnimationTree
onready var swordHitbox = $HitboxPivot/SwordHitbox
onready var hurtbox = $PlayerHurtbox


# This gets access to the root of animation tree
onready var animationState = animationTree.get("parameters/playback")


func _ready():
	randomize()
	stats.connect("no_health", self, "queue_free")
	swordHitbox.knockback_vector = roll_vector

func _process(delta):
	match state:
		MOVE:
			move_state(delta)
		ATTACK:
			attack_state(delta)
		ROLL:
			roll_state(delta)

func move_state(delta):
	# Takes the input of left/right up/down and creates an input for 8 directional movement. 
	var input_vector = Vector2.ZERO 
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	# Normalize the vector to always have the same input value or 0 (IE moves the same speed in all directions)
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		# Sets roll vector to input vector only if we are moving
		roll_vector = input_vector
		swordHitbox.knockback_vector = input_vector
		# Moving the speed towards MAX_SPEED by ACCELERATION
		# Allowing the setting of Idle/Run to be in accordance to input_vector
		animationTree.set("parameters/Idle/blend_position", input_vector)
		animationTree.set("parameters/Run/blend_position", input_vector)
		animationTree.set("parameters/Attack/blend_position", input_vector)
		animationTree.set("parameters/Roll/blend_position", input_vector)
		#Sets run state for animations
		animationState.travel("Run")
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		# Sets idle state for animations
		animationState.travel("Idle")
		# Creating friction to slow the character down
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
	# Move
	move()
	
	# Attack state trigger
	if Input.is_action_just_pressed("attack"):
		state = ATTACK
	if Input.is_action_just_pressed("roll"):
		state = ROLL

func attack_state(delta):
	velocity = Vector2.ZERO
	animationState.travel("Attack")

func attack_animation_finished():
	state = MOVE

func move():
	velocity = move_and_slide(velocity)

func roll_state(delta):
	move()
	hurtbox.start_invincibility(0.2)
	velocity = roll_vector * ROLL_SPEED
	animationState.travel("Roll")

func roll_animation_finished():
	velocity = Vector2.ZERO
	state = MOVE


func _on_PlayerHurtbox_area_entered(area):
	stats.health -= 1
	hurtbox.start_invincibility(0.5)
	hurtbox.create_hit_effect()
	print(stats.health)
