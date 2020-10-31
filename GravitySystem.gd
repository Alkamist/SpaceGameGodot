extends Node
class_name GravitySystem


var targets: Array
var sources: Array


func update_targets_and_sources() -> void:
    sources.clear()
    targets.clear()

    for child in get_children():
        if child.has_node("Body"):
            targets.append(child.get_node("Body"))

    for target in targets:
        if "gravity_strength" in target:
            sources.append(target)


func apply_gravity(source: GravitySource, target) -> void:
    var source_position: Vector3 = source.global_transform.origin
    var target_position: Vector3 = target.global_transform.origin
    var gravity_vector: Vector3 = (source_position - target_position)
    var target_distance: float = gravity_vector.length()
    var gravity_direction: Vector3 = gravity_vector.normalized()

    if target_distance > 0.0:
        var distance_from_surface: float = max(0.0, target_distance - source.source_radius)
        var distance_from_full_gravity: float = max(0.0, distance_from_surface - source.full_gravity_distance)
        var gravity_intensity: float

        if distance_from_full_gravity > 0.0:
            var gravity_scale: float = max(0.0, 1.0 - distance_from_full_gravity / source.fading_gravity_distance)
            gravity_intensity = source.gravity_strength * gravity_scale
        else:
            gravity_intensity = source.gravity_strength

        target.gravity += gravity_direction * gravity_intensity

        if "up_normal" in target:
            target.up_normal = -gravity_direction

        #if "is_in_atmosphere" in target:
        #    target.is_in_atmosphere = distance_from_full_gravity <= 0.0


func _ready() -> void:
    update_targets_and_sources()


func _physics_process(_delta: float) -> void:
    for target in targets:
        target.gravity = Vector3.ZERO

    for source in sources:
        for target in targets:
            apply_gravity(source, target)
