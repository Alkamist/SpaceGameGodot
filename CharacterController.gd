extends SpaceObject
class_name CharacterController


export(NodePath) var gravity_list_path
export(NodePath) var gravity_tween_path
export(NodePath) var head_path
export(float) var mouse_sensitivity = 1.0
export(float) var movement_acceleration := 20.0
export(float) var jump_strength := 15.0

onready var gravity_list: GravityList = get_node(gravity_list_path)
onready var gravity_tween: Tween = get_node(gravity_tween_path)
onready var head: Spatial = get_node(head_path)

var gravity_normal := Vector3.DOWN
var closest_gravity_source: GravitySource
var forward_movement := 0.0
var strafe_movement := 0.0
var gravity_rotation_weight := 1.0


func _initiate_orientation_to_new_gravity_source() -> void:
    gravity_rotation_weight = 0.0
    gravity_tween.interpolate_property(self, "gravity_rotation_weight",
        0.0, 1.0, 1.0,
        Tween.TRANS_EXPO, Tween.EASE_IN)
    gravity_tween.start()


func _vector_to_gravity_source(source: GravitySource) -> Vector3:
    var position: Vector3 = body.get_global_transform().origin
    var source_position: Vector3 = source.body.get_global_transform().origin
    return source_position - position


func _update_closest_gravity_source() -> void:
    var sources: Array = gravity_list.sources
    for source in sources:
        if closest_gravity_source == null:
            closest_gravity_source = source
        else:
            var closest_distance: float = _vector_to_gravity_source(closest_gravity_source).length()
            var source_distance: float = _vector_to_gravity_source(source).length()
            if source_distance < closest_distance:
                closest_gravity_source = source
                _initiate_orientation_to_new_gravity_source()


func _handle_gravity_rotation() -> void:
    var orientation_basis: Basis = orientation.transform.basis
    var angle_to_up: float = orientation_basis.y.angle_to(-gravity_normal)
    if angle_to_up > 0.0:
        var rotation_axis: Vector3 = orientation_basis.y.cross(-gravity_normal).normalized()
        var target_transform: Transform = orientation.transform.rotated(rotation_axis, angle_to_up)
        orientation.transform = orientation.transform.interpolate_with(target_transform, gravity_rotation_weight)


func _handle_mouse_looking(mouse_change: Vector2) -> void:
    if mouse_change.length() > 0.0:
        var horizontal: float = -mouse_change.x * (mouse_sensitivity / 10.0)
        var vertical: float = -mouse_change.y * (mouse_sensitivity / 10.0)

        var rotation_axis: Vector3 = orientation.transform.basis.y.normalized()
        orientation.transform = orientation.transform.rotated(rotation_axis, deg2rad(horizontal))
        head.rotate_x(deg2rad(vertical))

        var rotation: Vector3 = head.rotation_degrees
        rotation.x = clamp(rotation.x, -90.0, 90.0)
        head.rotation_degrees = rotation


func _ready() -> void:
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _input(event: InputEvent) -> void:
    if event is InputEventMouseMotion:
        if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
            return
        _handle_mouse_looking(event.relative)


func _process(_delta: float) -> void:
    forward_movement = Input.get_action_strength("move_forward") - Input.get_action_strength("move_backward")
    strafe_movement = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")


func _physics_process(delta: float) -> void:
    _update_closest_gravity_source()

    gravity_normal = _vector_to_gravity_source(closest_gravity_source).normalized()

    _handle_gravity_rotation()

    var orientation_basis: Basis = orientation.transform.basis
    var forward: Vector3 = -orientation_basis.z.normalized()
    var sideways: Vector3 = orientation_basis.x.normalized()
    var movement_direction: Vector3 = forward * forward_movement + sideways * strafe_movement

    velocity += movement_direction * movement_acceleration * delta

    #if body.is_on_floor():
    #    if Input.is_action_just_pressed("jump"):
    #        velocity += up_normal * jump_strength

    velocity = body.move_and_slide(
        velocity,
        -gravity_normal,
        false,
        4,
        0.785398,
        true
    )
