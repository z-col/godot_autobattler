# PlayerStats 类用于管理玩家的核心属性，包括金币、经验和等级。
# 
# 功能：
# - 存储和管理玩家的金币（gold）、经验（xp）、等级（level）等数据。
# - 提供经验升级所需的经验值查询。
# - 通过 set 方法实现属性变更时自动发出 changed 信号，便于 UI 或其他系统实时响应。
# 
# 属性说明：
# - gold: 玩家当前金币数量。
# - xp: 玩家当前经验值。
# - level: 玩家当前等级。
# - XP_REQUIREMENTS: 每个等级升级所需的经验值映射表。
# 
# 主要方法：
# - get_current_xp_requirement: 获取当前等级升级所需的经验值。
# - _set_gold/_set_xp/_set_level: 属性变更时自动发出 changed 信号。
class_name PlayerStats extends Resource


const XP_REQUIREMENTS = {
	1: 0,
	2: 2,
	3: 2,
	4: 6,
	5: 10,
	6: 20,
	7: 36,
	8: 48,
	9: 76,
	10: 76,
}


@export_range(0, 99) var gold: int: set = _set_gold
@export_range(0, 99) var xp: int: set = _set_xp
@export_range(1, 10) var level: int: set = _set_level


func get_current_xp_requirement() -> int:
	return XP_REQUIREMENTS[level + 1]


func _set_gold(value: int) -> void:
	gold = value
	emit_changed()


func _set_xp(value: int) -> void:
	xp = value
	emit_changed()


func _set_level(value: int) -> void:
	level = value
	emit_changed()
