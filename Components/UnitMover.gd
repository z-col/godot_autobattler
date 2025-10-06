# UnitMover 类用于管理单位的拖拽、放置和移动逻辑。
# 
# 功能：
# - 监听单位的拖拽事件（开始、取消、结束）。
# - 根据拖拽操作动态更新单位的位置。
# - 确保单位只能放置在有效的区域内，并处理目标格子被占用的情况。
# - 提供高亮显示功能，提示可放置的区域。
# 
# 属性：
# - play_areas: 存储所有可用的 PlayArea 区域。
# 
# 方法：
# - setup_unit: 为单位绑定拖拽相关的信号。
# - _set_highlighter: 启用或禁用所有 PlayArea 的高亮显示。
# - _get_play_area_for_position: 根据全局坐标获取对应的 PlayArea 索引。
# - _reset_unit_to_starting_position: 将单位重置到起始位置。
# - _move_unit: 将单位移动到指定的 PlayArea 和格子。
# - _on_unit_drag_started: 处理单位拖拽开始时的逻辑。
# - _on_unit_drag_canceled: 处理单位拖拽取消时的逻辑。
# - _on_unit_dropped: 处理单位拖拽结束时的逻辑。
class_name UnitMover extends Node


@export var play_areas: Array[PlayArea]


func _ready() -> void:
	var nuits = get_tree().get_nodes_in_group("units")
	for unit: Unit in nuits:
		setup_unit(unit)


func setup_unit(unit: Unit) -> void:
	unit.drag_and_drop.drag_started.connect(_on_unit_drag_started.bind(unit))
	unit.drag_and_drop.drag_canceled.connect(_on_unit_drag_canceled.bind(unit))
	unit.drag_and_drop.dropped.connect(_on_unit_dropped.bind(unit))


func _set_highlighter(enabled: bool) -> void:
	for play_area: PlayArea in play_areas:
		play_area.tile_highlighter.enabled = enabled


func _get_play_area_for_position(global: Vector2) -> int:
	var dropped_area_index = -1

	for i in play_areas.size():
		var tile = play_areas[i].get_tile_from_global(global)
		if play_areas[i].is_tile_in_bounds(tile):
			dropped_area_index = i

	return dropped_area_index

func _reset_unit_to_starting_position(starting_position: Vector2, unit: Unit) -> void:
	var i = _get_play_area_for_position(starting_position)
	var tile = play_areas[i].get_tile_from_global(starting_position)

	unit.reset_after_dragging(starting_position)
	play_areas[i].unit_grid.add_unit(tile, unit)


func _move_unit(unit: Unit, play_area: PlayArea, tile: Vector2i) -> void:
	play_area.unit_grid.add_unit(tile, unit)
	unit.global_position = play_area.get_global_from_tile(tile) - Arena.HALF_CELL_SIZE
	unit.reparent(play_area.unit_grid)


func _on_unit_drag_started(unit: Unit) -> void:
	_set_highlighter(true)

	var i = _get_play_area_for_position(unit.global_position)
	if i > -1:
		var tile = play_areas[i].get_tile_from_global(unit.global_position)
		play_areas[i].unit_grid.remove_unit(tile)

func _on_unit_drag_canceled(starting_position: Vector2, unit: Unit) -> void:
	_set_highlighter(false)
	_reset_unit_to_starting_position(starting_position, unit)


# 处理单位拖放结束时的逻辑。
# 如果单位被拖到无效区域，则重置回原位置。
# 如果目标格子已被其他单位占用，则将原单位移回原位置，当前单位占据新格子。
# 否则直接将单位移动到目标区域的目标格子。
func _on_unit_dropped(starting_position: Vector2, unit: Unit) -> void:
	_set_highlighter(false)

	var old_area_index = _get_play_area_for_position(starting_position)
	var drop_area_index = _get_play_area_for_position(unit.get_global_mouse_position())

	if drop_area_index == -1:
		_reset_unit_to_starting_position(starting_position, unit)
		return
	
	var old_area = play_areas[old_area_index]
	var old_tile = old_area.get_tile_from_global(starting_position)
	var new_area = play_areas[drop_area_index]
	var new_tile = new_area.get_hovered_tile()

	if new_area.unit_grid.is_tile_occupied(new_tile):
		var old_unit: Unit = new_area.unit_grid.units[new_tile]
		new_area.unit_grid.remove_unit(new_tile)
		_move_unit(old_unit, old_area, old_tile)
	
	_move_unit(unit, new_area, new_tile)