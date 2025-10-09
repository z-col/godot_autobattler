# RerollButton 类用于实现商店刷新按钮的交互逻辑。
# 
# 功能：
# - 监听玩家金币变化，自动更新按钮的可用状态和视觉效果。
# - 当玩家金币不足时，按钮禁用并显示半透明效果。
# - 当玩家点击按钮时，消耗2金币并触发刷新操作（实际刷新逻辑可在其他地方实现）。
# 
# 属性说明：
# - player_stats: 玩家属性对象，用于获取和修改金币。
# - hbox_container: 按钮内部的容器节点，用于调整视觉透明度。
# 
# 主要方法：
# - _on_player_stats_changed: 根据金币数量更新按钮状态和透明度。
# - _on_pressed: 响应按钮点击事件，消耗金币。
class_name RerollButton extends Button


@export var player_stats: PlayerStats


@onready var hbox_container: HBoxContainer = $HBoxContainer


func _ready() -> void:
	player_stats.changed.connect(_on_player_stats_changed)
	_on_player_stats_changed()


func _on_player_stats_changed() -> void:
	var has_enough_gold = player_stats.gold >= 2
	disabled = not has_enough_gold

	if has_enough_gold:
		hbox_container.modulate.a = 1.0
	else:
		hbox_container.modulate.a = 0.5

func _on_pressed() -> void:
	player_stats.gold -= 2
