extends Spatial
class_name RelativeMover


var movement_parent: Spatial setget set_movement_parent
var previous_movement_parent: Spatial

var movement_parent_transform: Transform
var movement_parent_previous_transform: Transform

signal movement_parent_changed


func set_movement_parent(value: Spatial) -> void:
    previous_movement_parent = movement_parent
    movement_parent = value
    movement_parent_previous_transform = movement_parent.get_global_transform()
    movement_parent_transform = movement_parent.get_global_transform()
    if movement_parent != previous_movement_parent:
        emit_signal("movement_parent_changed")


func move_relatively(target: Spatial) -> void:
    if movement_parent:
        # Displace by the amount the parent moved.
        target.transform.origin += movement_parent_transform.origin - movement_parent_transform.origin

        var relative_quaternion: Quat = movement_parent_transform.basis.get_rotation_quat() \
            * movement_parent_previous_transform.basis.get_rotation_quat().inverse()

        # Rotate relatively to the parent.
        target.transform.basis = Basis(target.transform.basis.get_rotation_quat() * relative_quaternion)

        var target_vector: Vector3 = target.get_global_transform().origin - movement_parent_transform.origin
        var target_vector_after_rotation: Vector3 = relative_quaternion.xform(target_vector)

        # Displace via rotation to stay in the same location relative to the parent.
        target.transform.origin += target_vector_after_rotation - target_vector

        # Rotate the velocity vector if present.
        var target_parent = target.get_parent()
        if "velocity" in target_parent:
            target_parent.velocity = relative_quaternion.xform(target_parent.velocity)


func update_parent_transform() -> void:
    if movement_parent:
        movement_parent_previous_transform = movement_parent_transform
        movement_parent_transform = movement_parent.get_global_transform()
    else:
        movement_parent_previous_transform = Transform()
        movement_parent_transform = Transform()
