class_name PlayArea extends TileMapLayer


@export var unit_grid: UnitGrid


var bounds: Rect2i

func _ready() -> void:
	bounds = Rect2i(Vector2i.ZERO, unit_grid.size)

# 返回整数坐标对应的本地坐标 ps:鼠标移入第一个瓦片的整个位置 , 都只显示(0,0)
func get_tile_from_global(global: Vector2) -> Vector2i:
	return local_to_map(to_local(global))


func get_global_from_tile(tile: Vector2i) -> Vector2:
	return to_global(map_to_local(tile))

# 将局部鼠标位置转化为整数瓦片位置.
func get_hovered_tile() -> Vector2i:
	return local_to_map(get_local_mouse_position())

# 检查是否在我们指定的举行内.
func is_tile_in_bounds(tile: Vector2i) -> bool:
	return bounds.has_point(tile)