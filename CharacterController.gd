extends Spatial
class_name CharacterController


export(Vector3) var velocity := Vector3.ZERO
export(float) var mouse_sensitivity = 1.0
export(float) var ground_speed := 40.0
export(float) var ground_acceleration := 1000.0
export(float) var ground_traction := 1000.0
export(float) var air_speed := 40.0
export(float) var air_acceleration := 200.0
export(float) var air_traction := 3.0
export(float) var jetpack_speed := 80.0
export(float) var jetpack_acceleration := 200.0
export(float) var jump_strength := 50.0

onready var body: KinematicBody = get_node("Body")
onready var head: Spatial = get_node("Smoothing/Head")

var up_normal := Vector3.UP setget set_up_normal

var is_on_ground := false
var is_in_atmosphere := false
var forward_movement := 0.0
var strafe_movement := 0.0
var gravity_rotation_weight := 1.0
var max_move_recursions := 4
var move_recursions := 0


func set_up_normal(value: Vector3) -> void:
    up_normal = value
    var angle_to_up: float = body.transform.basis.y.angle_to(up_normal)
    if angle_to_up > 0.0:
        var rotation_axis: Vector3 = body.transform.basis.y.cross(up_normal).normalized()
        body.transform.basis = body.transform.basis.rotated(rotation_axis, angle_to_up)


func horizontal_velocity_movement_addition(target: Vector3, acceleration: float, traction: float) -> Vector3:
    var movement_plane: Plane = Plane(up_normal, 0.0)
    var target_in_movement_plane: Vector3 = movement_plane.project(target)
    var velocity_in_movement_plane: Vector3 = movement_plane.project(velocity)
    var velocity_and_target_are_in_same_direction: bool = velocity_in_movement_plane.dot(target_in_movement_plane) >= 0.0
    var modifier: float

    if velocity_and_target_are_in_same_direction \
    and velocity_in_movement_plane.length() > target_in_movement_plane.length():
        modifier = traction
    else:
        modifier = acceleration

    return velocity_in_movement_plane.move_toward(target_in_movement_plane, modifier) - velocity_in_movement_plane


func handle_mouse_looking(mouse_change: Vector2) -> void:
    if mouse_change.length() > 0.0:
        var horizontal: float = -mouse_change.x * (mouse_sensitivity / 10.0)
        var vertical: float = -mouse_change.y * (mouse_sensitivity / 10.0)

        body.transform.basis = body.transform.basis.rotated(body.transform.basis.y.normalized(), deg2rad(horizontal))

        head.rotate_x(deg2rad(vertical))
        var rotation: Vector3 = head.rotation_degrees
        rotation.x = clamp(rotation.x, -90.0, 90.0)
        head.rotation_degrees = rotation


func handle_horizontal_movement(delta: float, speed: float, acceleration: float, traction: float) -> void:
    if forward_movement != 0.0 or strafe_movement != 0.0:
        var forward: Vector3 = -body.transform.basis.z.normalized()
        var sideways: Vector3 = body.transform.basis.x.normalized()
        var movement_direction: Vector3 = (forward * forward_movement + sideways * strafe_movement).normalized()
        velocity += horizontal_velocity_movement_addition(
            movement_direction * speed,
            acceleration * delta,
            traction * delta
        )
    else:
        velocity += horizontal_velocity_movement_addition(
            Vector3.ZERO,
            traction * delta,
            traction * delta
        )


func handle_jetpack_movement(delta: float) -> void:
    var upward_velocity: Vector3 = up_normal * velocity.dot(up_normal)
    velocity += upward_velocity.move_toward(up_normal * jetpack_speed, jetpack_acceleration * delta) - upward_velocity


func check_if_on_ground(tolerance_distance: float) -> void:
    var collision: KinematicCollision = body.move_and_collide(-up_normal * tolerance_distance, true, true, true)
    is_on_ground = collision != null


func move(distance: Vector3) -> void:
    var collision: KinematicCollision = body.move_and_collide(distance, true, true, false)

    if collision and move_recursions < max_move_recursions:
        move_recursions += 1
        velocity = velocity.slide(collision.normal)
        move(collision.remainder.slide(collision.normal))
    else:
        move_recursions = 0


func _ready() -> void:
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _input(event: InputEvent) -> void:
    if event is InputEventMouseMotion:
        if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
            return
        handle_mouse_looking(event.relative)


func _process(_delta: float) -> void:
    forward_movement = Input.get_action_strength("move_forward") - Input.get_action_strength("move_backward")
    strafe_movement = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")


func _physics_process(delta: float) -> void:
    check_if_on_ground(0.2)

    if is_on_ground:
        if Input.is_action_just_pressed("jump"):
            velocity += up_normal * jump_strength

        handle_horizontal_movement(delta, ground_speed, ground_acceleration, ground_traction)
    else:
        if Input.is_action_pressed("jump"):
            handle_jetpack_movement(delta)

        handle_horizontal_movement(delta, air_speed, air_acceleration, air_traction if is_in_atmosphere else 0.0)

    move(velocity * delta)
