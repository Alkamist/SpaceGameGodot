extends RigidBody
class_name DeadItem


var gravity := Vector3.ZERO


func _integrate_forces(state: PhysicsDirectBodyState) -> void:
    state.add_central_force(gravity * mass)
