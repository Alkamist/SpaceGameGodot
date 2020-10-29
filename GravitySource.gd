extends Spatial
class_name GravitySource


export(Vector3) var velocity := Vector3.ZERO
export(float) var gravity_strength = 9.81
export(float) var source_radius = 200.0
export(float) var full_gravity_distance = 500.0
export(float) var fading_gravity_distance = 500.0

onready var body: KinematicBody = get_node("Body")
onready var previous_position: Vector3 = get_global_transform().origin

var movement := Vector3.ZERO
var is_gravity_source := true


func _physics_process(delta: float) -> void:
    previous_position = body.get_global_transform().origin

    #var collision: KinematicCollision = body.move_and_collide(velocity * delta, true, true, true)
    #if collision:
    #    if "is_gravity_source" in collision.collider \
    #    and collision.collider.is_gravity_source:
    #        velocity = Vector3.ZERO

    body.translate(velocity * delta)

    movement = body.get_global_transform().origin - previous_position
