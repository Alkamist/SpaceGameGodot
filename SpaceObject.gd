extends Node
class_name SpaceObject


export(NodePath) var body_path
export(NodePath) var orientation_path
export(Vector3) var initial_velocity = Vector3.ZERO

onready var body: KinematicBody = get_node(body_path)
onready var orientation: Orientation = get_node(orientation_path)
onready var velocity: Vector3 = initial_velocity


func _physics_process(_delta: float) -> void:
    velocity = body.move_and_slide(
        velocity,
        Vector3.UP,
        false,
        4,
        0.785398,
        true
    )
