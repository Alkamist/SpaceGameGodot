extends Spatial
class_name GravitySource


export(Vector3) var velocity := Vector3.ZERO
export(Vector3) var spin := Vector3.ZERO
export(float) var gravity_strength = 9.81
export(float) var source_radius = 200.0
export(float) var full_gravity_distance = 500.0
export(float) var fading_gravity_distance = 500.0

onready var body: KinematicBody = get_node("Body")

var is_gravity_source := true


func _physics_process(delta: float) -> void:
    #var collision: KinematicCollision = body.move_and_collide(velocity * delta, true, true, true)
    #if collision:
    #    if "is_gravity_source" in collision.collider \
    #    and collision.collider.is_gravity_source:
    #        velocity = Vector3.ZERO

    if velocity != Vector3.ZERO:
        body.transform.origin += velocity * delta

    if spin != Vector3.ZERO:
        body.rotate(spin.normalized(), spin.length() * delta)
        body.transform = body.transform.orthonormalized()
