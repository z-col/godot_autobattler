# UnitGrid 类用于管理一个网格状的单位分布。
# 
# 功能：
# - 维护一个单位的网格映射，支持添加、移除单位。
# - 提供网格状态查询，例如检查某个格子是否被占用、网格是否已满。
# - 支持获取所有单位或第一个空闲格子。
# - 通过信号 unit_grid_changed 通知外部网格状态的变化。
class_name UnitGrid extends Node2D


signal unit_grid_changed


@export var size: Vector2i


var units: Dictionary


func _ready() -> void:
	for i in size.x:
		for j in size.y:
			units[Vector2i(i, j)] = null


func add_unit(tile: Vector2i, unit: Node) -> void:
	units[tile] = unit
	unit_grid_changed.emit()


func remove_unit(tile: Vector2i) -> void:
	var unit = units[tile]

	if not unit:
		return

	units[tile] = null
	unit_grid_changed.emit()


func is_tile_occupied(tile: Vector2i) -> bool:
	return units[tile] != null


func is_grid_full() -> bool:
	return units.keys().all(is_tile_occupied)

func get_first_empty_tile() -> Vector2i:
	for tile in units:
		if not is_tile_occupied(tile):
			return tile
	
	return Vector2i(-1, -1)


func get_all_units() -> Array[Unit]:
	var unit_array: Array[Unit] = []

	for unit: Unit in units.values():
		if unit:
			unit_array.append(unit)

	return unit_array
