extends Spatial

const J_STAND = 0.00113204  # from CAD, kg * m^2
const J_FLYWHEEL = 0.00108912  # from CAD, kg * m^2
const FRICTION_BEARING = 0.0005  # guessed, N * m
const FRICTION_MOTOR = 0.003  # guessed, N * m
const MOTOR_STALL_TORQUE = 0.1079  # 8.3 * 13 A / 1000 kv, N * m
const MOTOR_KV = 1000.0  # from motor datasheet
const MAX_VOLTAGE = 12.0  # from motor datasheet

var velocity_stand = 0.0  # rad / s
var velocity_flywheel = 0.0  # rad / s

var momentum_stand = 0.0
var momentum_flywheel = 0.0

var motor_power = 0.0  # on a scale of 0.0 to 1.0 (0% to 100%)
var time = 0

func _ready():
	heavy()
#	light()




func _physics_process(delta):
	
	_update_momentum()
	
	_apply_motor_impulse(delta)
	_apply_motor_friction(delta)
	_apply_stand_friction(delta)
	
	_update_velocity()
	_update_rotation(delta)
	
	_update_motor_power()
	
	time += delta


# physics update functions -----------------------------------------------------

func _update_momentum():
	momentum_stand = velocity_stand * J_STAND
	momentum_flywheel = velocity_flywheel * J_FLYWHEEL

func _apply_motor_impulse(delta: float):
	var motor_impulse = motor_power * MOTOR_STALL_TORQUE * delta * 0.1
	momentum_stand -= motor_impulse
	momentum_flywheel += motor_impulse

func _apply_motor_friction(delta: float):
	var momentum_difference = momentum_flywheel - momentum_stand
	var friction_torque = -sign(momentum_difference) * FRICTION_MOTOR * delta
	if abs(friction_torque) > abs(momentum_difference):
		friction_torque = -momentum_difference
	
	momentum_stand -= friction_torque
	momentum_flywheel += friction_torque

func _apply_stand_friction(delta: float):
	momentum_stand = derp(momentum_stand, 0, FRICTION_BEARING * delta)

func _update_velocity():
	velocity_stand = momentum_stand / J_STAND
	velocity_flywheel = momentum_flywheel / J_FLYWHEEL

func _update_rotation(delta: float):
	$RotatingStand.rotate_z(velocity_stand * delta)
	$Flywheel.rotate_z(velocity_flywheel * delta)

func _update_motor_power():
	motor_power = 0.0
	
	if Input.is_key_pressed(KEY_SPACE):
		motor_power = cos(time / 1) * 0.5
	
	if Input.is_key_pressed(KEY_D):
		motor_power = 1.0
	
	if Input.is_key_pressed(KEY_A):
		motor_power = -1.0

# utility functions ------------------------------------------------------------

func light():
	for node in get_children():
		if node.has_node("Light"):
			node.get_node("Light").show()
			node.get_node("Heavy").hide()
		else:
			if node.has_method("hide"):
				node.hide()

func heavy():
	for node in get_children():
		if node.has_node("Light"):
			node.get_node("Light").show()
			node.get_node("Heavy").show()
		if node.has_method("show"):
			node.show()

# constant velocity interpolation using a given step size
func derp(from: float, to: float, step: float):
	if from < to:
		return clamp(from + step, from, to)
	if from > to:
		return clamp(from - step, to, from)
	return to
