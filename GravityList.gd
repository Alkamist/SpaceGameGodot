extends Node
class_name GravityList


var targets: Array
var sources: Array


func update_targets_and_sources() -> void:
    sources.clear()
    targets.clear()

    for child in get_children():
        if child.has_node("Body"):
            targets.append(child.get_node("Body"))

    for target in targets:
        if target is GravitySource:
            sources.append(target)


func apply_gravity(delta: float, source: GravitySource, target: SpaceObject) -> void:
    var source_position: Vector3 = source.get_global_transform().origin
    var target_position: Vector3 = target.get_global_transform().origin
    var gravity_vector: Vector3 = (source_position - target_position)
    var target_distance: float = gravity_vector.length()
    var gravity_direction: Vector3 = gravity_vector.normalized()
    if target_distance > 0.0:
        var distance_from_surface: float = max(0.0, target_distance - source.source_radius)
        var distance_from_full_gravity: float = max(0.0, distance_from_surface - source.full_gravity_distance)

        var gravity_intensity: float
        if distance_from_full_gravity > 0.0:
            var gravity_scale: float = max(0.0, 1.0 - distance_from_full_gravity / source.cutoff_gravity_distance)
            gravity_intensity = source.gravity_strength * gravity_scale
        else:
            gravity_intensity = source.gravity_strength

        target.velocity += gravity_direction * gravity_intensity * delta


func _ready() -> void:
    update_targets_and_sources()


func _physics_process(delta: float) -> void:
    for source in sources:
        for target in targets:
            if "bound_gravity_source" in target:
                if target.bound_gravity_source == source \
                or target.bound_gravity_source == null:
                    apply_gravity(delta, source, target)
            else:
                apply_gravity(delta, source, target)
