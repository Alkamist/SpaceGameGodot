extends Node
class_name CharacterController


export(float) var mouse_sensitivity = 1.0

onready var smoothing: Spatial = get_node("Smoothing")
onready var head: Spatial = get_node("Smoothing/Head")
onready var body: PhysicsBody = get_node("Body")

var look_rotation: Vector2 = Vector2.ZERO


func on_body_planet_changed() -> void:
    if body.previous_planet:
        if body.previous_planet.is_connected("changed_rotation", self, "on_planet_changed_rotation"):
            body.previous_planet.disconnect("changed_rotation", self, "on_planet_changed_rotation")

    if body.planet:
        body.planet.connect("changed_rotation", self, "on_planet_changed_rotation")


func on_planet_changed_rotation(spin_axis: Vector3, delta_spin: float) -> void:
    smoothing.transform.basis = smoothing.transform.basis.rotated(spin_axis, delta_spin)


func handle_mouse_looking(mouse_change: Vector2) -> void:
    if mouse_change.length() > 0.0:
        look_rotation.x -= mouse_change.x * (mouse_sensitivity / 350.0)
        look_rotation.y += mouse_change.y * (mouse_sensitivity / 350.0)
        look_rotation.y = clamp(look_rotation.y, deg2rad(-89.0), deg2rad(89.0))
        head.transform.basis = Basis()
        head.rotate_object_local(Vector3(0, 1, 0), look_rotation.x)
        head.rotate_object_local(Vector3(1, 0, 0), look_rotation.y)


func _ready() -> void:
    body.connect("planet_changed", self, "on_body_planet_changed")
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _input(event: InputEvent) -> void:
    if event is InputEventMouseMotion:
        if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
            return
        handle_mouse_looking(event.relative)


func _process(_delta: float) -> void:
    smoothing.transform.origin = body.transform.origin

    var angle_to_up: float = smoothing.transform.basis.y.angle_to(body.up_normal)
    if angle_to_up > 0.0:
        var rotation_axis: Vector3 = smoothing.transform.basis.y.cross(body.up_normal).normalized()
        smoothing.transform.basis = smoothing.transform.basis.rotated(rotation_axis, angle_to_up)

    body.forward_movement = Input.get_action_strength("move_forward") - Input.get_action_strength("move_backward")
    body.strafe_movement = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
    body.look_direction = head.global_transform.basis.z.normalized()

    smoothing.transform.basis = smoothing.transform.basis.orthonormalized()
    head.transform.basis = head.transform.basis.orthonormalized()
