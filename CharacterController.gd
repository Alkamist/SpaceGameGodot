extends Node
class_name CharacterController


export(float) var mouse_sensitivity = 1.0

onready var smoothing: Spatial = get_node("Smoothing")
onready var head: Spatial = get_node("Smoothing/Head")
onready var body: PhysicsBody = get_node("Body")

var look_rotation: Vector2 = Vector2.ZERO

func set_look_direction(value: Vector3) -> void: body.look_direction = value
func get_look_direction() -> Vector3: return body.look_direction
func set_gravity(value: Vector3) -> void: body.gravity = value
func get_gravity() -> Vector3: return body.gravity
func set_up_normal(value: Vector3) -> void: body.up_normal = value
func get_up_normal() -> Vector3: return body.up_normal
func set_forward_movement(value: float) -> void: body.forward_movement = value
func get_forward_movement() -> float: return body.forward_movement
func set_strafe_movement(value: float) -> void: body.strafe_movement = value
func get_strafe_movement() -> float: return body.strafe_movement


func handle_mouse_looking(mouse_change: Vector2) -> void:
    if mouse_change.length() > 0.0:
        look_rotation.x -= mouse_change.x * (mouse_sensitivity / 350.0)
        look_rotation.y += mouse_change.y * (mouse_sensitivity / 350.0)
        look_rotation.y = clamp(look_rotation.y, deg2rad(-90.0), deg2rad(90.0))
        head.transform.basis = Basis()
        head.rotate_object_local(Vector3(0, 1, 0), look_rotation.x)
        head.rotate_object_local(Vector3(1, 0, 0), look_rotation.y)
        head.transform.basis = head.transform.basis.orthonormalized()
        set_look_direction(Plane(get_up_normal(), 0.0).project(head.global_transform.basis.z.normalized()))


func _ready() -> void:
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _input(event: InputEvent) -> void:
    if event is InputEventMouseMotion:
        if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
            return
        handle_mouse_looking(event.relative)


func _process(_delta: float) -> void:
    smoothing.transform.origin = body.transform.origin
    var angle_to_up: float = smoothing.transform.basis.y.angle_to(get_up_normal())
    if angle_to_up > 0.0:
        var rotation_axis: Vector3 = smoothing.transform.basis.y.cross(get_up_normal()).normalized()
        smoothing.transform.basis = smoothing.transform.basis.rotated(rotation_axis, angle_to_up)

    set_forward_movement(Input.get_action_strength("move_forward") - Input.get_action_strength("move_backward"))
    set_strafe_movement(Input.get_action_strength("move_right") - Input.get_action_strength("move_left"))
