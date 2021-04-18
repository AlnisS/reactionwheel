extends Node


# System constants
#const J_STAND = 5.0
#const J_FLYWHEEL = 5.0
#const FRICTION_BEARING = 0.4
#const ANGULAR_VELOCITY_TO_ESC_OUTPUT = 4.0

const J_STAND = 0.00113204  # from CAD, kg * m^2
const J_FLYWHEEL = 0.00108912 / 15.0 # from CAD, kg * m^2
const FRICTION_BEARING = 0.0005  # guessed, N * m
#const FRICTION_MOTOR = 0.003  # guessed, N * m
const MOTOR_STALL_TORQUE = 0.1079  # 8.3 * 13 A / 1000 kv, N * m
const MOTOR_KV = 1000.0  # from motor datasheet
const MAX_VOLTAGE = 12.0  # from motor datasheet

const ANGULAR_VELOCITY_TO_ESC_OUTPUT = 1.0 / (MOTOR_KV * MAX_VOLTAGE * 2 * PI)

const P = 0.3
const I = 0.1
const D = 0.0

# Initial sensor measurements
var velocity_stand: float = 0.0
var velocity_flywheel: float = 0.0

# Controller inputs
var velocity_target: float = 0.0

var last_delta_v = 0
var delta_v_i = 0.0

var time := 0.0

func _physics_process(delta):
#	update_sensors()
#	var momentum_stand = velocity_stand * J_STAND
#	var momentum_flywheel = velocity_flywheel * J_FLYWHEEL
#	var momentum_stand_target = velocity_target * J_STAND
#
#	var delta_momentum_stand_target = momentum_stand_target - momentum_stand
#	var momentum_flywheel_target = delta_momentum_stand_target + momentum_flywheel
#	var velocity_flywheel_target = momentum_flywheel_target / J_FLYWHEEL
#
#	var esc_output = -ANGULAR_VELOCITY_TO_ESC_OUTPUT * velocity_flywheel_target
#	esc_write(esc_output)
	
	velocity_target = PI * sin(time * 0.2)
	
	update_sensors()
	
	# error
	var delta_v = velocity_target - velocity_stand
	# change in error divided by time step = derivative
	var delta_delta_v = (last_delta_v - delta_v) / delta
	# integrate error
	delta_v_i += delta_v * delta
	
	last_delta_v = delta_v
	
	
	
	var esc_output = delta_v * P + delta_v_i * I + delta_delta_v * D
	
	# motor spins opposite direction from stand velocity
	esc_output = -esc_output
	
	print("delta_v: " + str(delta_v)
			+ "\ndelta_delta_v: " + str(delta_delta_v)
			+ "\ndelta_v_i: " + str(delta_v_i)
			+ "\nesc_output: " + str(esc_output)
			+ "\n")
	
	esc_write(esc_output)

	time += delta
	

func update_sensors():
	velocity_stand = get_parent().velocity_stand
	velocity_flywheel = get_parent().velocity_flywheel

func esc_write(esc_output):
	get_parent().esc_input = clamp(esc_output, -1, 1)

