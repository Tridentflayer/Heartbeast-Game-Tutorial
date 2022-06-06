extends KinematicBody2D

var knockback = Vector2.ZERO
var KNOCKBACK = 120

export var ACCELERATION = 300
export var MAX_SPEED = 50
export var AIR_FRICTION = 200

const EnemyDeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")

onready var stats = $Stats
onready var playerDetectionZone = $PlayerDetectionZone
onready var sprite = $BatAnimated
onready var hurtbox = $Hurtbox
onready var softCollision = $SoftCollision
onready var wanderController = $WanderController


enum{
	IDLE,
	WANDER,
	FOLLOW
} 

var velocity = Vector2.ZERO
var state = IDLE

func _process(delta):
	# Creating on hit knockback
	knockback = knockback.move_toward(Vector2.ZERO, AIR_FRICTION * delta)
	knockback = move_and_slide(knockback)
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, AIR_FRICTION * delta)
			seek_player()
			if wanderController.get_time_left() == 0:
				state = pick_random_state([IDLE, WANDER])
				wanderController.start_wander_timer(rand_range(1, 3))
		WANDER:
			seek_player()
			if wanderController.get_time_left() == 0:
				state = pick_random_state([IDLE, WANDER])
				wanderController.start_wander_timer(rand_range(1, 2))
				
			var direction = global_position.direction_to(wanderController.target_position)
			velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
			
			if global_position.distance_to(wanderController.target_position) <= MAX_SPEED * delta:
				state = pick_random_state([IDLE, WANDER])
				wanderController.start_wander_timer(rand_range(1, 3))
		FOLLOW:
			# Makes the sprite flap faster if it's chasing you
			sprite.set_speed_scale(1.5)
			# Flips sprite according to direction
			sprite.flip_h = velocity.x < 0
			# Allows bat to follow the player, by subtracting the bats position from the players
			var player = playerDetectionZone.player
			if player != null:
				var direction = global_position.direction_to(player.global_position)
				velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
			else:
				state = IDLE
	# Soft collision handling
	if softCollision.is_colliding():
		velocity += softCollision.get_push_vector() * delta * 400
	velocity = move_and_slide(velocity)

func seek_player():
	sprite.set_speed_scale(1)
	if playerDetectionZone.can_see_player():
		state = FOLLOW

func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()


func _on_Hurtbox_area_entered(area):
	# Damage
	stats.health -= area.damage
	knockback = area.knockback_vector * 120
	hurtbox.create_hit_effect()

func _on_Stats_no_health():
	# Death effect and death
	queue_free()
	var enemyDeathEffect = EnemyDeathEffect.instance()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.global_position = global_position
