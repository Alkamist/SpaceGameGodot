extends RigidBody


var gravity := Vector3.ZERO
#var gravity := Vector3(0.0, -9.81, 0.0)


func _integrate_forces(state: PhysicsDirectBodyState) -> void:
    state.add_central_force(gravity * mass)
