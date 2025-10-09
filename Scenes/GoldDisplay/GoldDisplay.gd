# GoldDisplay 类用于显示玩家当前金币数量。
# 
# 功能：
# - 监听玩家金币变化，自动刷新金币显示。
# - 通过绑定 PlayerStats 的 changed 信号，实现金币变化时 UI 的实时更新。
# 
# 属性说明：
# - player_stats: 玩家属性对象，用于获取金币数据。
# - gold: 用于显示金币数值的 Label 节点。
# 
# 主要方法：
# - _on_player_stats_changed: 当金币变化时，刷新金币显示。
class_name GoldDisplay extends HBoxContainer


@export var player_stats: PlayerStats


@onready var gold: Label = $Gold


func _ready() -> void:
	player_stats.changed.connect(_on_player_stats_changed)
	_on_player_stats_changed()


func _on_player_stats_changed() -> void:
	gold.text = str(player_stats.gold)