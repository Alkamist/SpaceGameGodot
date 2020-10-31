extends RigidBody
class_name GravitySource


export(Vector3) var spin := Vector3.ZERO
export(float) var gravity_strength = 9.81
export(float) var source_radius = 200.0
export(float) var full_gravity_distance = 500.0
export(float) var fading_gravity_distance = 500.0

var gravity := Vector3.ZERO


func _integrate_forces(state: PhysicsDirectBodyState) -> void:
    state.add_central_force(gravity)
    state.set_angular_velocity(spin)
