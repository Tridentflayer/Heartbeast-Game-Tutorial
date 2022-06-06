extends Node

export(int) var max_health = 1 setget set_max_health

export(int) var damage
# Creates a variable that whenever it is changed, it triggers a function
# In this case, set_health
var health = max_health setget set_health

# Creating a signal for no health and then emitting it when health = 0
signal no_health
signal health_changed
signal max_health_changed

func set_max_health(value):
	max_health = value
	self.health = min(health, max_health)
	emit_signal("max_health_changed", max_health)

func set_health(value):
	health = value
	emit_signal("health_changed", health)
	if health <= 0:
		emit_signal("no_health")

func _ready():
	self.health = max_health
