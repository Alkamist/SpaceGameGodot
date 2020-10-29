extends Spatial


export(NodePath) var target_path

onready var target: Spatial = get_node(target_path)

onready var current_transform: Transform = target.transform
onready var previous_transform: Transform = target.transform


func _physics_process(_delta: float) -> void:
    previous_transform = current_transform
    current_transform = target.transform


func _process(_delta: float) -> void:
    #var interpolation = Engine.get_physics_interpolation_fraction()
    #transform.origin = previous_transform.origin.linear_interpolate(current_transform.origin, interpolation)
    #transform.basis = previous_transform.basis.orthonormalized().slerp(current_transform.basis.orthonormalized(), interpolation)
    transform = current_transform
