extends Node


# System constants
const J_STAND = 5.0
const J_FLYWHEEL = 5.0
const FRICTION_BEARING = 0.4
const ANGULAR_VELOCITY_TO_ESC_OUTPUT = 4.0

# Initial sensor measurements
var velocity_stand: float = 0.0
var velocity_flywheel: float = 0.0

# Controller inputs
var velocity_target: float = 15


func _physics_process(delta):
	update_sensors()

func update_sensors():
	pass

func esc_write():
	pass

