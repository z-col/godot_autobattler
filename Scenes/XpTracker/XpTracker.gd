# XpTracker 类用于显示和追踪玩家的经验值和等级进度。
#
# 功能：
# - 监听玩家经验和等级变化，自动刷新经验条和等级显示。
# - 支持进度条显示当前经验进度，满级时显示最大值。
# - 支持通过快捷键（如“ui_accept”）增加经验，便于测试和调试。
#
# 属性说明：
# - player_stats: 玩家属性对象，用于获取和修改经验、等级。
# - progress_bar: 经验进度条节点。
# - xplabel: 显示当前经验值的标签。
# - level_label: 显示当前等级的标签。
#
# 主要方法：
# - _on_player_stats_changed: 根据经验和等级刷新进度条和标签。
# - _set_xp_bar_values: 设置进度条和经验标签的数值。
# - _set_max_level_values: 满级时的进度条和标签显示。
# - _input: 支持通过按键增加经验。
class_name XpTracker extends VBoxContainer


@export var player_stats: PlayerStats


@onready var progress_bar: ProgressBar = %ProgressBar
@onready var xplabel: Label = %XPLabel
@onready var level_label: Label = %LevelLabel


func _ready() -> void:
	player_stats.changed.connect(_on_player_stats_changed)
	_on_player_stats_changed()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		player_stats.xp += 4
		print("XP increased to: ", player_stats.xp)


func _on_player_stats_changed() -> void:
	if player_stats.level < 10:
		_set_xp_bar_values()
	else:
		_set_max_level_values()

	level_label.text = "lvl: %s" % player_stats.level


func _set_max_level_values() -> void:
	progress_bar.value = 100
	xplabel.text = "XP: MAX"


func _set_xp_bar_values() -> void:
	var xp_requirement: float = player_stats.get_current_xp_requirement()
	progress_bar.value = player_stats.xp / xp_requirement * 100
	xplabel.text = "%s/%s" % [player_stats.xp, int(xp_requirement)]
