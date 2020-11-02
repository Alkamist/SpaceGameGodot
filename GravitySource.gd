extends RigidBody
class_name GravitySource


export(Vector3) var spin = Vector3.ZERO
export(float) var gravity_strength = 9.81
export(float) var source_radius = 200.0
export(float) var full_gravity_distance = 500.0
export(float) var fading_gravity_distance = 500.0

var gravity := Vector3.ZERO
onready var previous_transform := transform

signal changed_rotation


func perpendicular_vector(input_vector: Vector3) -> Vector3:
    if input_vector.angle_to(Vector3.UP) > 0.0:
        return input_vector.cross(input_vector + Vector3.UP).normalized()
    return Vector3.RIGHT


func _integrate_forces(state: PhysicsDirectBodyState) -> void:
    state.add_central_force(gravity * mass)
    state.set_angular_velocity(spin)

    var spin_perpendicular: Vector3 = perpendicular_vector(spin)
    var delta_spin: float = previous_transform.basis.xform(spin_perpendicular).angle_to(transform.basis.xform(spin_perpendicular))
    emit_signal("changed_rotation", spin.normalized(), delta_spin)
    previous_transform = transform
