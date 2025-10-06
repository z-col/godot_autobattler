# UnitSpawner 类用于管理单位的生成与放置。
# 
# 功能：
# - 在 bench（备战区）或 game_area（战斗区）中寻找空位生成新单位。
# - 负责实例化单位场景，并将其添加到对应区域的 UnitGrid。
# - 通过 unit_spawned 信号通知外部有新单位生成，便于后续逻辑（如拖拽绑定等）。
# 
# 属性：
# - bench: 备战区 PlayArea。
# - game_area: 战斗区 PlayArea。
# 
# 方法：
# - _get_first_available_area: 返回第一个有空位的区域。
# - spawn_unit: 在可用区域生成新单位并完成必要的初始化。
class_name UnitSpawner extends Node


signal unit_spawned(unit: Unit)


const UNIT = preload("res://Scenes/Unit/Unit.tscn")


@export var bench: PlayArea
@export var game_area: PlayArea


func _get_first_available_area() -> PlayArea:
	if not bench.unit_grid.is_grid_full():
		return bench
	elif not game_area.unit_grid.is_grid_full():
		return game_area

	return null


func spawn_unit(unit: UnitsState) -> void:
	var area = _get_first_available_area()

	#TODO 在未来 ,这里将使用弹出式UI抛出没有空位的信息
	assert(area, "No available area to spawn unit")

	var new_unit = UNIT.instantiate()
	var tile: Vector2i = area.unit_grid.get_first_empty_tile()
	area.unit_grid.add_child(new_unit)
	area.unit_grid.add_unit(tile, new_unit)
	new_unit.global_position = area.get_global_from_tile(tile) - Arena.HALF_CELL_SIZE
	new_unit.state = unit
	unit_spawned.emit(new_unit)