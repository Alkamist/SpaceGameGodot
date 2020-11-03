extends Node
class_name SpaceShipController


export(float) var mouse_sensitivity = 1.0

onready var mouse_readout: Spatial = get_node("Smoothing/MouseReadout")
onready var smoothing: Spatial = get_node("Smoothing")
onready var body: PhysicsBody = get_node("Body")

onready var current_body_transform: Transform = body.transform
onready var previous_body_transform: Transform = body.transform


func handle_mouse_looking(mouse_change: Vector2) -> void:
    if mouse_change.length() > 0.0:
        body.mouse_control.x -= mouse_change.x * (mouse_sensitivity / 350.0)
        body.mouse_control.x = clamp(body.mouse_control.x, -1.0, 1.0)
        body.mouse_control.y += mouse_change.y * (mouse_sensitivity / 350.0)
        body.mouse_control.y = clamp(body.mouse_control.y, -1.0, 1.0)
        mouse_readout.transform.origin.x = body.mouse_control.x * 1.5
        mouse_readout.transform.origin.y = -body.mouse_control.y * 1.5


func _ready() -> void:
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _input(event: InputEvent) -> void:
    if event is InputEventMouseMotion:
        if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
            return
        handle_mouse_looking(event.relative)


func _physics_process(_delta: float) -> void:
    previous_body_transform = current_body_transform
    current_body_transform = body.transform


func _process(_delta: float) -> void:
    var interpolation: float = Engine.get_physics_interpolation_fraction()

    smoothing.transform.origin = previous_body_transform.origin.linear_interpolate(current_body_transform.origin, interpolation)
    smoothing.transform.basis = previous_body_transform.basis.slerp(current_body_transform.basis, interpolation)

    body.thrust_control.z = Input.get_action_strength("thrust_forward") - Input.get_action_strength("thrust_backward")
    body.thrust_control.x = Input.get_action_strength("thrust_left") - Input.get_action_strength("thrust_right")
    body.thrust_control.y = Input.get_action_strength("thrust_up") - Input.get_action_strength("thrust_down")
    body.roll_control = Input.get_action_strength("roll_left") - Input.get_action_strength("roll_right")

    smoothing.transform.basis = smoothing.transform.basis.orthonormalized()
