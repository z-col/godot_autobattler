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