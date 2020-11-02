extends Spatial


onready var smoothing: Spatial = get_node("Smoothing")
onready var body: Spatial = get_node("Body")

onready var current_transform: Transform = body.transform
onready var previous_transform: Transform = body.transform


func _physics_process(_delta: float) -> void:
    previous_transform = current_transform
    current_transform = body.transform


func _process(_delta: float) -> void:
    var interpolation = Engine.get_physics_interpolation_fraction()
    smoothing.transform.origin = previous_transform.origin.linear_interpolate(current_transform.origin, interpolation)
    smoothing.transform.basis = previous_transform.basis.slerp(current_transform.basis, interpolation)
    smoothing.transform = smoothing.transform.orthonormalized()
