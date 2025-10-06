# PlayArea 类用于表示游戏中的一个可交互区域，通常是单位可以放置或移动的区域。
# 
# 功能：
# - 提供瓦片（Tile）的坐标转换功能，包括全局坐标与本地瓦片坐标的互相转换。
# - 检查瓦片是否在有效范围内。
# - 提供高亮功能以提示可交互区域。
# 
# 属性：
# - unit_grid: 管理该区域内单位分布的网格。
# - tile_highlighter: 用于高亮显示可交互瓦片的组件。
# - bounds: 定义该区域的边界范围。
# 
# 方法：
# - get_tile_from_global: 将全局坐标转换为瓦片坐标。
# - get_global_from_tile: 将瓦片坐标转换为全局坐标。
# - get_hovered_tile: 获取当前鼠标悬停的瓦片坐标。
# - is_tile_in_bounds: 检查给定的瓦片是否在区域边界内。
class_name PlayArea extends TileMapLayer


@export var unit_grid: UnitGrid
@export var tile_highlighter: TileHighlighter


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