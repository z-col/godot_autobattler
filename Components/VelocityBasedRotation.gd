class_name VelocityBasedRotation extends Node


@export var enabled: bool = true: set = _set_enabled
@export var target: Node2D
@export_range(0.25, 1.5) var lerp_seconds: float = 0.4 # 单位旋转到位置所需的时间
@export var max_rotation_degrees: int = 50 # 单位最大旋转度数
@export var x_velocity_threshold: float = 3.0 # 单位旋转最小速度 , 如果没达到这个速度将不旋转


var last_position: Vector2 # 上一帧的位置,利用上一帧的位置和当前帧的位置计算拖住速度
var velocity: Vector2
var angle: float
var progress: float
var time_elapsed: float = 0.0 # 记录开始旋转过了多少时间


func _physics_process(delta: float) -> void:
	if not enabled or not target:
		return
	
	velocity = target.global_position - last_position
	last_position = target.global_position
	progress = time_elapsed / lerp_seconds

	if abs(velocity.x) > x_velocity_threshold:
		angle = velocity.normalized().x * deg_to_rad(max_rotation_degrees)
	else:
		angle = 0.0

	target.rotation = lerp_angle(target.rotation, angle, progress)
	time_elapsed += delta

	if progress >= 1.0:
		time_elapsed = 0.0


func _set_enabled(value: bool) -> void:
	enabled = value

	if target and enabled == false:
		target.rotation = 0.0