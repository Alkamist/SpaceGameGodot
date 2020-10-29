extends SpaceObject
class_name CharacterController


export(NodePath) var gravity_list_path
export(NodePath) var gravity_tween_path
export(NodePath) var head_path
export(float) var mouse_sensitivity = 1.0
export(float) var ground_speed := 50.0
export(float) var ground_acceleration := 1000.0
export(float) var ground_traction := 1000.0
export(float) var air_speed := 25.0
export(float) var air_acceleration := 80.0
export(float) var air_traction := 80.0
export(float) var jetpack_speed := 100.0
export(float) var jetpack_acceleration := 200.0
export(float) var jump_strength := 50.0

onready var gravity_list: GravityList = get_node(gravity_list_path)
onready var gravity_tween: Tween = get_node(gravity_tween_path)
onready var head: Spatial = get_node(head_path)

var is_on_ground := false
var closest_gravity_source: GravitySource
var bound_gravity_source: GravitySource
var gravity_normal: Vector3
var up_normal: Vector3
var forward_movement := 0.0
var strafe_movement := 0.0
var gravity_rotation_weight := 1.0
var max_move_recursions := 4
var move_recursions := 0


func horizontal_velocity_movement_addition(target: Vector3, weight: float) -> Vector3:
    var movement_plane: Plane = Plane(up_normal, 0.0)
    var target_in_movement_plane: Vector3 = movement_plane.project(target)
    var velocity_in_movement_plane: Vector3 = movement_plane.project(velocity)
    return velocity_in_movement_plane.move_toward(target_in_movement_plane, weight) - velocity_in_movement_plane


func initiate_orientation_to_new_gravity_source() -> void:
    gravity_rotation_weight = 0.0
    gravity_tween.interpolate_property(self, "gravity_rotation_weight",
        0.0, 1.0, 1.0,
        Tween.TRANS_EXPO, Tween.EASE_IN)
    gravity_tween.start()


func vector_to_gravity_source(source: GravitySource) -> Vector3:
    var position: Vector3 = get_global_transform().origin
    var source_position: Vector3 = source.get_global_transform().origin
    return source_position - position


func update_gravity_source() -> void:
    for source in gravity_list.sources:
        if closest_gravity_source == null:
            closest_gravity_source = source
        else:
            var closest_distance: float = vector_to_gravity_source(closest_gravity_source).length()
            var source_distance: float = vector_to_gravity_source(source).length()
            if source_distance < closest_distance:
                closest_gravity_source = source
                initiate_orientation_to_new_gravity_source()

    var gravity_influence_distance: float = closest_gravity_source.source_radius \
                                          + closest_gravity_source.full_gravity_distance \
                                          + closest_gravity_source.cutoff_gravity_distance

    if vector_to_gravity_source(closest_gravity_source).length() < gravity_influence_distance:
        bound_gravity_source = closest_gravity_source
    else:
        bound_gravity_source = null


func handle_gravity_rotation() -> void:
    var orientation_basis: Basis = orientation.transform.basis
    var angle_to_up: float = orientation_basis.y.angle_to(up_normal)
    if angle_to_up > 0.0:
        var rotation_axis: Vector3 = orientation_basis.y.cross(up_normal).normalized()
        var target_transform: Transform = orientation.transform.rotated(rotation_axis, angle_to_up)
        orientation.transform = orientation.transform.interpolate_with(target_transform, gravity_rotation_weight)


func handle_mouse_looking(mouse_change: Vector2) -> void:
    if mouse_change.length() > 0.0:
        var horizontal: float = -mouse_change.x * (mouse_sensitivity / 10.0)
        var vertical: float = -mouse_change.y * (mouse_sensitivity / 10.0)

        var rotation_axis: Vector3 = orientation.transform.basis.y.normalized()
        orientation.transform = orientation.transform.rotated(rotation_axis, deg2rad(horizontal))
        head.rotate_x(deg2rad(vertical))

        var rotation: Vector3 = head.rotation_degrees
        rotation.x = clamp(rotation.x, -90.0, 90.0)
        head.rotation_degrees = rotation


func handle_grounded_horizontal_movement(delta: float) -> void:
    if forward_movement != 0.0 or strafe_movement != 0.0:
        var forward: Vector3 = -orientation.transform.basis.z.normalized()
        var sideways: Vector3 = orientation.transform.basis.x.normalized()
        var movement_direction: Vector3 = (forward * forward_movement + sideways * strafe_movement).normalized()
        velocity += horizontal_velocity_movement_addition(movement_direction * ground_speed, ground_acceleration * delta)
    else:
        velocity += horizontal_velocity_movement_addition(Vector3.ZERO, ground_traction * delta)


func handle_aerial_horizontal_movement(delta: float) -> void:
    if forward_movement != 0.0 or strafe_movement != 0.0:
        var forward: Vector3 = -orientation.transform.basis.z.normalized()
        var sideways: Vector3 = orientation.transform.basis.x.normalized()
        var movement_direction: Vector3 = (forward * forward_movement + sideways * strafe_movement).normalized()
        velocity += horizontal_velocity_movement_addition(movement_direction * air_speed, air_acceleration * delta)
    else:
        velocity += horizontal_velocity_movement_addition(Vector3.ZERO, air_traction * delta)


func handle_jetpack_movement(delta: float) -> void:
    var upward_velocity: Vector3 = up_normal * velocity.dot(up_normal)
    velocity += upward_velocity.move_toward(up_normal * jetpack_speed, jetpack_acceleration * delta) - upward_velocity


func check_if_on_ground(tolerance_distance: float) -> void:
    var collision: KinematicCollision = move_and_collide(gravity_normal * tolerance_distance, true, true, true)
    is_on_ground = collision != null


func move(distance: Vector3) -> void:
    var collision: KinematicCollision = move_and_collide(distance, true, true, false)

    if collision and move_recursions < max_move_recursions:
        move_recursions += 1

        #if collision.collider is SpaceObject:
        #    if collision.collider.is_gravity_source:
        #        bound_gravity_source = collision.collider

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
    if gravity_list:
        update_gravity_source()

    if bound_gravity_source:
        gravity_normal = vector_to_gravity_source(bound_gravity_source).normalized()
        up_normal = -gravity_normal
        handle_gravity_rotation()

    check_if_on_ground(0.2)

    if is_on_ground:
        if Input.is_action_just_pressed("jump"):
            velocity += up_normal * jump_strength

        handle_grounded_horizontal_movement(delta)

    else:
        if Input.is_action_pressed("jump"):
            handle_jetpack_movement(delta)

        handle_aerial_horizontal_movement(delta)

    move(velocity * delta)

    if bound_gravity_source:
        translate(bound_gravity_source.movement)
