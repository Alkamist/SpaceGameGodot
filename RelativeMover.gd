extends KinematicBody
class_name RelativeMover


var movement_parent: Spatial setget set_movement_parent
var previous_movement_parent: Spatial

var movement_parent_current_transform := Transform()
var movement_parent_previous_transform := Transform()
var movement_parent_relative_quat := Quat()

signal movement_parent_changed


func set_movement_parent(value: Spatial) -> void:
    previous_movement_parent = movement_parent
    movement_parent = value

    if movement_parent != previous_movement_parent:
        if movement_parent != null:
            movement_parent_current_transform = movement_parent.transform
            movement_parent_previous_transform = movement_parent.transform
            movement_parent_relative_quat = Quat()

            var global_origin: Vector3 = global_transform.origin

            get_parent().remove_child(self)
            movement_parent.add_child(self)

            transform.origin = movement_parent.to_local(global_origin)
            transform.basis *= movement_parent.transform.basis.inverse()
#        else:
#            movement_parent_current_transform = Transform()
#            movement_parent_previous_transform = Transform()
#            movement_parent_relative_quat = Quat()
#
#            var global_origin: Vector3 = global_transform.origin
#
#            get_parent().remove_child(self)
#            previous_movement_parent.get_parent().add_child(self)
#
#            transform.origin = global_origin
#            transform.basis *= previous_movement_parent.transform.basis

        emit_signal("movement_parent_changed")


func _physics_process(_delta: float) -> void:
    if movement_parent:
        movement_parent_previous_transform = movement_parent_current_transform
        movement_parent_current_transform = movement_parent.transform
        movement_parent_relative_quat = movement_parent_current_transform.basis.get_rotation_quat() \
            * movement_parent_previous_transform.basis.get_rotation_quat().inverse()
