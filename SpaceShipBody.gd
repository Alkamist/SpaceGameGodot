extends RigidBody
class_name SpaceShipBody


var forward_thrust_strength := 40.0
var sideways_thrust_strength := 40.0
var upward_thrust_strength := 40.0

var yaw_strength := 4.0
var pitch_strength := 4.0
var roll_strength := 4.0

var thrust_control := Vector3.ZERO
var roll_control := 0.0
var mouse_control := Vector2(0.0, 0.0)
var gravity := Vector3.ZERO


func _integrate_forces(state: PhysicsDirectBodyState) -> void:
    state.add_central_force(gravity * mass)

    var forward_thrust: Vector3 = forward_thrust_strength * thrust_control.z * transform.basis.z
    var sideways_thrust: Vector3 = sideways_thrust_strength * thrust_control.x * transform.basis.x
    var upward_thrust: Vector3 = upward_thrust_strength * thrust_control.y * transform.basis.y
    var net_thrust: Vector3 = forward_thrust + sideways_thrust + upward_thrust
    state.add_central_force(net_thrust * mass)

    var yaw_torque: Vector3 = yaw_strength * mouse_control.x * transform.basis.y
    var pitch_torque: Vector3 = pitch_strength * mouse_control.y * transform.basis.x
    var roll_torque: Vector3 = roll_strength * -roll_control * transform.basis.z
    var net_torque: Vector3 = yaw_torque + pitch_torque + roll_torque
    state.add_torque(net_torque * mass)
