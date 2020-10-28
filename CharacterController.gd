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

var closest_gravity_source: GravitySource
var bound_gravity_source: GravitySource
var forward_movement := 0.0
var strafe_movement := 0.0
var gravity_rotation_weight := 1.0
var max_move_recursions := 4
var move_recursions := 0


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


func handle_gravity_rotation(gravity_normal: Vector3) -> void:
    var orientation_basis: Basis = orientation.transform.basis
    var angle_to_up: float = orientation_basis.y.angle_to(-gravity_normal)
    if angle_to_up > 0.0:
        var rotation_axis: Vector3 = orientation_basis.y.cross(-gravity_normal).normalized()
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
    update_gravity_source()

    if bound_gravity_source:
        var gravity_normal: Vector3 = vector_to_gravity_source(bound_gravity_source).normalized()
        handle_gravity_rotation(gravity_normal)

    var orientation_basis: Basis = orientation.transform.basis
    var forward: Vector3 = -orientation_basis.z.normalized()
    var sideways: Vector3 = orientation_basis.x.normalized()
    var movement_direction: Vector3 = forward * forward_movement + sideways * strafe_movement

    velocity += movement_direction * movement_acceleration * delta

    #if body.is_on_floor():
    #    if Input.is_action_just_pressed("jump"):
    #        velocity += up_normal * jump_strength

    move(velocity * delta)

    if bound_gravity_source:
        translate(bound_gravity_source.velocity * delta)
