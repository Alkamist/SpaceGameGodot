extends Spatial
class_name Orientation


export(Array, NodePath) var target_paths

var targets: Array
var previous_transform: Transform


func _ready() -> void:
    previous_transform = transform
    for path in target_paths:
        targets.append(get_node(path))


func update_target_transforms() -> void:
    var current_quat: Quat = transform.basis.get_rotation_quat()
    var previous_quat: Quat = previous_transform.basis.get_rotation_quat()
    var quat_difference: Quat = current_quat - previous_quat

    for target in targets:
        var target_quat: Quat = target.transform.basis.get_rotation_quat()
        target.transform.basis = Basis(target_quat + quat_difference)

    previous_transform = transform


func _physics_process(delta: float) -> void:
    update_target_transforms()
