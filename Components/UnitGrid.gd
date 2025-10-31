## UnitGrid：管理一个二维格子上的单位状态（用于 PlayArea）
#
# 功能：
# - 维护一个网格（字典映射 tile -> unit），支持添加/移除单位并发出变更通知。
# - 当单位从场景树移除时自动清理对应格子（通过监听单位的 tree_exited 信号）。
# - 提供常用查询方法：判断格子是否被占用、查找第一个空位、判断网格是否已满，以及获取所有单位列表。
#
# 属性说明：
# - size (Vector2i)：网格的宽高（格子数），用于初始化 `units` 字典的键。
# - units (Dictionary)：存放 <Vector2i, Unit?> 的映射，表示每个格子当前的单位或为空（null）。
# - signal unit_grid_changed：当网格内容修改时发出，供 UI 或父节点监听刷新。
#
# 主要方法：
# - _ready(): 初始化 `units` 字典，填充所有格子键并设为 null。
# - add_unit(tile, unit): 将单位放入指定格子，连接单位的 tree_exited 以便自动清理，并发出 unit_grid_changed。
# - remove_unit(tile): 从格子移除单位并断开 tree_exited 连接，发出 unit_grid_changed。
# - is_tile_occupied(tile): 返回格子是否被占用（非 null）。
# - is_grid_full(): 如果所有格子都被占用则返回 true。
# - get_first_empty_tile(): 返回第一个未被占用的格子坐标，若无返回 Vector2i(-1, -1)。
# - get_all_units(): 返回当前所有非空的 Unit 数组。
# - _on_unit_tree_exited(tile, unit): 内部回调，当单位从场景树移除时清理格子并发出变更信号。

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
	unit.tree_exited.connect(_on_unit_tree_exited.bind(unit, tile))
	unit_grid_changed.emit()


func remove_unit(tile: Vector2i) -> void:
	var unit = units[tile]

	if not unit:
		return


	unit.tree_exited.disconnect(_on_unit_tree_exited)
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


func _on_unit_tree_exited(unit: Unit, tile: Vector2i) -> void:
	if unit.is_queued_for_deletion():
		units[tile] = null
		unit_grid_changed.emit()
