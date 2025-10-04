"""
TileHighlighter组件功能解释
TileHighlighter是一个Godot引擎中的Node类组件，主要用于在游戏地图上高亮显示玩家当前悬停的瓦片(tile)。以下是它的具体功能： 
主要功能
瓦片高亮显示：当玩家鼠标悬停在地图上的某个瓦片时，会在该位置显示一个高亮效果
状态控制：可以通过enabled属性开启或关闭高亮功能
自动清理：当鼠标移出地图边界时，会自动清除高亮效果
关键属性
enabled：控制高亮功能是否启用
play_area：引用PlayArea节点，获取地图信息和悬停位置
highlight_layer：指定用于显示高亮的TileMapLayer层
tile：定义要使用哪个瓦片作为高亮效果
工作原理
在_process方法中持续检测： 
检查功能是否启用(enabled)
获取当前悬停的瓦片位置(get_hovered_tile)
检查位置是否在地图边界内(is_tile_in_bounds)
更新高亮显示(_update_tile)
_update_tile方法： 
先清除之前的高亮(clear)
在目标位置设置高亮瓦片(set_cell)
_set_enabled方法： 
当enabled属性改变时，如果禁用则清除高亮
"""
class_name TileHighlighter extends Node


@export var enabled: bool = true: set = _set_enabled
@export var play_area: PlayArea
@export var highlight_layer: TileMapLayer
@export var tile: Vector2i


@onready var source_id = play_area.tile_set.get_source_id(0)


var last_tile: Vector2i

func _process(_delta: float) -> void:
	if not enabled:
		return
	
	var selected_tile = play_area.get_hovered_tile()

	if not play_area.is_tile_in_bounds(selected_tile):
		highlight_layer.clear()
		return

	
	_update_tile(selected_tile)


func _update_tile(selected_tile: Vector2i) -> void:
	if selected_tile == last_tile:
		return
	print("selected_tile", selected_tile)
	print("last_tile", last_tile)
	highlight_layer.clear()
	highlight_layer.set_cell(selected_tile, source_id, tile)
	last_tile = selected_tile


func _set_enabled(value: bool) -> void:
	enabled = value
	if not enabled and play_area:
		highlight_layer.clear()
