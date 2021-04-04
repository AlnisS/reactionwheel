extends Spatial

const J_STAND = 0.00113204
const J_FLYWHEEL = 0.00108912
const FRICTION_BEARING = 0.0005
const FRICTION_MOTOR = 0.003
const MOTOR_TORQUE = 0.01

var velocity_stand = 0.0
var velocity_flywheel = 0.0

var motor_power = 1.0

func _ready():
	heavy()
#	light()

var time = 0

func _physics_process(delta):
	
	var momentum_stand = velocity_stand * J_STAND
	var momentum_flywheel = velocity_flywheel * J_FLYWHEEL
	
	var motor_torque = motor_power * MOTOR_TORQUE * delta
	
	momentum_stand -= motor_torque
	momentum_flywheel += motor_torque
	
	var momentum_difference = momentum_flywheel - momentum_stand
	var friction_torque = -sign(momentum_difference) * FRICTION_MOTOR * delta
	if abs(friction_torque) > abs(momentum_difference):
		friction_torque = -momentum_difference
	
	momentum_stand -= friction_torque
	momentum_flywheel += friction_torque
	
	momentum_stand = derp(momentum_stand, 0, FRICTION_BEARING * delta)
	
	
	velocity_stand = momentum_stand / J_STAND
	velocity_flywheel = momentum_flywheel / J_FLYWHEEL
	
	
	$RotatingStand.rotate_z(velocity_stand * delta)
	$Flywheel.rotate_z(velocity_flywheel * delta)
	
	motor_power = 0.0
	
	if Input.is_key_pressed(KEY_SPACE):
		motor_power = cos(time / 1) * 0.5
	
	if Input.is_key_pressed(KEY_D):
		motor_power = 1.0
	
	if Input.is_key_pressed(KEY_A):
		motor_power = -1.0
	
	
	
	time += delta


func momentum():
	return J_STAND * velocity_stand + J_FLYWHEEL * (velocity_flywheel + velocity_stand)


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

func derp(from: float, to: float, step: float):
	if from < to:
		return clamp(from + step, from, to)
	if from > to:
		return clamp(from - step, to, from)
	return to
