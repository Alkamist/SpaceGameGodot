extends Node
class_name GravitySystem


var targets: Array
var sources: Array


#func update_bound_gravity_source(source: GravitySource, target, target_position: Vector3, target_distance: float) -> void:
#    if "bound_gravity_source" in target:
#        var gravity_influence_distance: float = source.source_radius \
#                                              + source.full_gravity_distance \
#                                              + source.fading_gravity_distance
#
#        if target_distance <= gravity_influence_distance:
#            if target.bound_gravity_source:
#                var distance_to_existing_source: float = (target_position - target.bound_gravity_source.body.get_global_transform().origin).length()
#                if target_distance < distance_to_existing_source:
#                    target.bound_gravity_source = source
#            else:
#                target.bound_gravity_source = source


func update_targets_and_sources() -> void:
    sources.clear()
    targets.clear()

    for child in get_children():
        if child.has_node("Body"):
            targets.append(child)

    for target in targets:
        if "is_gravity_source" in target and target.is_gravity_source:
            sources.append(target)


func apply_gravity(delta: float, source: GravitySource, target) -> void:
    var source_position: Vector3 = source.body.get_global_transform().origin
    var target_position: Vector3 = target.body.get_global_transform().origin
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

        target.velocity += gravity_direction * gravity_intensity * delta

        if "relative_mover" in target:
            target.relative_mover.movement_parent = source.body

        #if "up_normal" in target:
        #    target.up_normal = -gravity_direction

        #if "is_in_atmosphere" in target:
        #    target.is_in_atmosphere = distance_from_full_gravity <= 0.0


func _ready() -> void:
    update_targets_and_sources()


func _physics_process(delta: float) -> void:
    for source in sources:
        for target in targets:
            apply_gravity(delta, source, target)
