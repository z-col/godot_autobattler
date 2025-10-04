class_name DragAndDrop extends Node


signal drag_canceled(starting_position: Vector2)
signal drag_started
signal dropped(ending_position: Vector2)


@export var enabled: bool = true
@export var target: Area2D


var starting_position: Vector2
var offset: Vector2 = Vector2.ZERO
var dragging: bool = false


func _ready() -> void:
	assert(target, "No target set for DragAndDrop Component!!")
	target.input_event.connect(_on_target_input_event.unbind(1))


func _process(_delta: float) -> void:
	if dragging and target:
		target.global_position = target.get_global_mouse_position() + offset

# 点击esc取消拖动 
# func _input(event: InputEvent) -> void:
# 	if dragging and target and event.is_action_released("cancel_drag"):
# 		_cancel_dragging()

# 点击鼠标左键结束拖动 解决拖动到目标后无法点击的问题
func _input(event: InputEvent) -> void:
	if dragging and event.is_action_pressed("cancel_drag"):
		_cancel_dragging()
	elif dragging and event.is_action_pressed("select"):
		_drop()

#结束拖动
func _end_dragging() -> void:
	dragging = false
	target.remove_from_group("dragging")
	target.z_index = 0

#取消拖动
func _cancel_dragging() -> void:
	_end_dragging()
	drag_canceled.emit(starting_position)

#开始拖动
func _start_dragging() -> void:
	dragging = true
	starting_position = target.global_position
	target.add_to_group("dragging")
	target.z_index = 99
	offset = target.global_position - target.get_global_mouse_position()
	drag_started.emit()

#放下目标
func _drop() -> void:
	_end_dragging()
	dropped.emit(starting_position)

#监听目标的输入事件
func _on_target_input_event(_viewport: Node, event: InputEvent) -> void:
	if not enabled:
		return
	#获取当前拖动的对象
	var dragging_object = get_tree().get_first_node_in_group("dragging")

	if not dragging and dragging_object:
		return

	if not dragging and event.is_action_pressed("select"):
		_start_dragging()
