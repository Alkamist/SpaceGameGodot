extends Node
class_name GravityList


var targets: Array
var sources: Array


func update_targets_and_sources() -> void:
    sources.clear()
    targets = get_children()
    for target in targets:
        if target is GravitySource:
            sources.append(target)


func _ready() -> void:
    update_targets_and_sources()


func _apply_gravity(delta: float, source: GravitySource, target: SpaceObject) -> void:
    var source_position: Vector3 = source.body.get_global_transform().origin
    var target_position: Vector3 = target.body.get_global_transform().origin
    var gravity_direction: Vector3 = (source_position - target_position).normalized()
    target.velocity += gravity_direction * source.gravity_strength * delta


func _physics_process(delta: float) -> void:
    for source in sources:
        for target in targets:
            _apply_gravity(delta, source, target)
