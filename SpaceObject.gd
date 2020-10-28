extends KinematicBody
class_name SpaceObject


export(NodePath) var orientation_path
export(Vector3) var initial_velocity = Vector3.ZERO

onready var orientation: Orientation = get_node(orientation_path)
onready var velocity: Vector3 = initial_velocity setget set_velocity

var is_gravity_source := false


func set_velocity(value: Vector3) -> void:
    velocity = value
