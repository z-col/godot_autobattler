# XpButton 类用于实现经验购买按钮的交互逻辑。
#
# 功能：
# - 监听玩家金币和等级变化，自动更新按钮的可用状态和视觉效果。
# - 当玩家金币足够且未满级时，允许点击按钮购买经验，消耗金币并增加经验值。
# - 按钮禁用时显示为不可点击状态，提升用户体验。
#
# 属性说明：
# - player_stats: 玩家属性对象，用于获取和修改金币、经验、等级。
# - vbox_container: 按钮内部的容器节点，用于调整视觉透明度。
#
# 主要方法：
# - _on_player_stats_changed: 根据金币和等级更新按钮状态和透明度。
# - _on_pressed: 响应按钮点击事件，消耗金币并增加经验。
class_name XpButton extends Button


@export var player_stats: PlayerStats


@onready var vbox_container: VBoxContainer = $VBoxContainer


func _ready() -> void:
	player_stats.changed.connect(_on_player_stats_changed)
	_on_player_stats_changed()


func _on_player_stats_changed() -> void:
	var has_enough_gold = player_stats.gold >= 4
	var level_10 = player_stats.level == 10
	disabled = not has_enough_gold or level_10

	if has_enough_gold and not level_10:
		vbox_container.modulate.a = 1.0
	else:
		vbox_container.modulate.a = 0.5

func _on_pressed() -> void:
	player_stats.gold -= 4
	player_stats.xp += 4
