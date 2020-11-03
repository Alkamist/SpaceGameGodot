extends RigidBody
class_name CharacterBody


var look_direction := Vector3(0.0, 0.0, 1.0)
var gravity := Vector3.ZERO
var ground_speed := 10.0
var ground_acceleration := 100.0
var ground_traction := 100.0
var jetpack_acceleration := 100.0
var jump_speed := 4.0
var forward_movement := 0.0
var strafe_movement := 0.0
var can_jump := false

var up_normal := Vector3.UP
var start_up_normal := Vector3.UP
var target_up_normal := Vector3.UP
var up_normal_tween := Tween.new()
var up_normal_interpolation := 0.0

var planet: GravitySource setget set_planet
var previous_planet: GravitySource
func set_planet(value: GravitySource) -> void:
    previous_planet = planet
    planet = value
    if planet != previous_planet:
        tween_up_normal()
        emit_signal("planet_changed")

signal planet_changed


func horizontal_velocity_addition(movement_plane: Plane,
                                  current: Vector3,
                                  target: Vector3,
                                  acceleration: float,
                                  traction: float) -> Vector3:
    var target_in_movement_plane: Vector3 = movement_plane.project(target)
    var current_in_movement_plane: Vector3 = movement_plane.project(current)
    var current_and_target_are_in_same_direction: bool = current_in_movement_plane.dot(target_in_movement_plane) >= 0.0
    var modifier: float

    if current_and_target_are_in_same_direction \
    and current_in_movement_plane.length() > target_in_movement_plane.length():
        modifier = traction
    else:
        modifier = acceleration

    return current_in_movement_plane.move_toward(target_in_movement_plane, modifier) - current_in_movement_plane


func horizontal_movement(state: PhysicsDirectBodyState, speed: float, acceleration: float, traction: float) -> void:
    if forward_movement != 0.0 or strafe_movement != 0.0:
        physics_material_override.friction = 0.0
        var movement_plane: Plane = Plane(up_normal, 0.0)
        var forward: Vector3 = movement_plane.project(look_direction.normalized())
        var sideways: Vector3 = look_direction.cross(up_normal).normalized()
        var movement_direction: Vector3 = (forward * forward_movement + sideways * strafe_movement).normalized()
        state.add_central_force(movement_direction * ground_acceleration * mass)
        #state.set_linear_velocity(state.linear_velocity + horizontal_velocity_addition(
        #    movement_plane,
        #    state.linear_velocity,
        #    movement_direction * speed,
        #    acceleration * state.step,
        #    traction * state.step
        #))
    else:
        physics_material_override.friction = 4.0


func stay_upright(state: PhysicsDirectBodyState) -> void:
    var angle: float = transform.basis.y.angle_to(up_normal)
    if angle > 0.0:
        var rotation_axis: Vector3 = transform.basis.y.cross(up_normal).normalized()
        state.set_angular_velocity(rotation_axis * angle / state.step)


func tween_up_normal() -> void:
    start_up_normal = up_normal
    up_normal_interpolation = 0.0
    up_normal_tween.interpolate_property(self, "up_normal_interpolation",
        0.0, 1.0, 1.0,
        Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
    up_normal_tween.start()


func _ready() -> void:
    add_child(up_normal_tween)
    up_normal_tween.set_tween_process_mode(Tween.TWEEN_PROCESS_PHYSICS)


func _integrate_forces(state: PhysicsDirectBodyState) -> void:
    if planet:
        var vector_from_planet: Vector3 = global_transform.origin - planet.global_transform.origin
        if vector_from_planet.length() <= planet.source_radius + planet.full_gravity_distance:
            target_up_normal = vector_from_planet.normalized()
        else:
            set_planet(null)

    up_normal = start_up_normal.linear_interpolate(target_up_normal, up_normal_interpolation)

    #for contact_id in state.get_contact_count():
    #    print(state.get_contact_local_position(contact_id))

    state.add_central_force(gravity * mass)
    horizontal_movement(state, ground_speed, ground_acceleration, ground_traction)
    stay_upright(state)

    #if can_jump and Input.is_action_pressed("jump"):
    #    state.apply_central_impulse(up_normal * jump_speed * mass)
    #    can_jump = false

    if Input.is_action_pressed("jump"):
        state.add_central_force(up_normal * jetpack_acceleration * mass)

    if Input.is_action_pressed("thrust_down"):
        state.add_central_force(-up_normal * jetpack_acceleration * mass)
