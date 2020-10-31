extends PhysicsBody
class_name CharacterBody


var up_normal := Vector3.UP
var look_direction := Vector3(0.0, 0.0, 1.0)
var gravity := Vector3.ZERO
var forward_movement := 0.0
var strafe_movement := 0.0


func _integrate_forces(state: PhysicsDirectBodyState) -> void:
    state.add_central_force(gravity)

    if forward_movement != 0.0 or strafe_movement != 0.0:
        var forward: Vector3 = look_direction.normalized()
        var sideways: Vector3 = look_direction.cross(up_normal).normalized()
        var movement_direction: Vector3 = (forward * forward_movement + sideways * strafe_movement).normalized()
        state.add_central_force(movement_direction * 50.0)

    var angle_to_up: float = transform.basis.y.angle_to(up_normal)
    if angle_to_up > 0.0:
        var rotation_axis: Vector3 = transform.basis.y.cross(up_normal).normalized()
        state.set_angular_velocity(rotation_axis * angle_to_up / state.get_step())
