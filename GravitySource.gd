extends SpaceObject
class_name GravitySource


export(float) var gravity_strength = 9.81
export(float) var source_radius = 200.0
export(float) var full_gravity_distance = 500.0
export(float) var cutoff_gravity_distance = 500.0

onready var previous_position: Vector3 = get_global_transform().origin

var movement := Vector3.ZERO


func _ready() -> void:
    is_gravity_source = true


func _physics_process(delta: float) -> void:
    previous_position = get_global_transform().origin

    var collision: KinematicCollision = move_and_collide(velocity * delta, true, true, true)

    if collision:
        if collision.collider is SpaceObject:
            if collision.collider.is_gravity_source:
                var new_velocity: Vector3 = collision.collider.velocity
                collision.collider.set_velocity(velocity)
                velocity = new_velocity

    translate(velocity * delta)

    movement = get_global_transform().origin - previous_position
