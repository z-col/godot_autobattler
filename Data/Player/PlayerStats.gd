## PlayerStats 类用于管理玩家的核心属性，包括金币、经验和等级，并自动处理升级和抽卡逻辑。
#
# 功能：
# - 存储和管理玩家的金币（gold）、经验（xp）、等级（level）等数据。
# - 提供经验升级所需的经验值查询。
# - 通过 set 方法实现属性变更时自动发出 changed 信号，便于 UI 或其他系统实时响应。
# - 在经验增加时自动判断并处理升级，支持多级连升。
# - 根据玩家等级，动态调整抽卡可获得的单位稀有度和概率。
#
# 属性说明：
# - gold: 玩家当前金币数量。
# - xp: 玩家当前经验值。
# - level: 玩家当前等级。
# - XP_REQUIREMENTS: 每个等级升级所需的经验值映射表。
# - ROLL_RARITIES: 每个等级可抽取的单位稀有度列表。
# - ROLL_CHANCES: 每个等级对应稀有度的抽取概率权重。
#
# 主要方法：
# - get_current_xp_requirement: 获取当前等级升级所需的经验值。
# - get_random_rarity_for_level: 按当前等级和权重随机抽取单位稀有度。
# - _set_gold/_set_xp/_set_level: 属性变更时自动发出 changed 信号。
#   - _set_xp 方法会在经验足够时自动升级，并处理多级升级和经验溢出。
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


const ROLL_RARITIES = {
	1: [UnitsState.Rarity.COMMON],
	2: [UnitsState.Rarity.COMMON],
	3: [UnitsState.Rarity.COMMON, UnitsState.Rarity.UNCOMMON],
	4: [UnitsState.Rarity.COMMON, UnitsState.Rarity.UNCOMMON, UnitsState.Rarity.RARE],
	5: [UnitsState.Rarity.COMMON, UnitsState.Rarity.UNCOMMON, UnitsState.Rarity.RARE],
	6: [UnitsState.Rarity.COMMON, UnitsState.Rarity.UNCOMMON, UnitsState.Rarity.RARE],
	7: [UnitsState.Rarity.COMMON, UnitsState.Rarity.UNCOMMON, UnitsState.Rarity.RARE, UnitsState.Rarity.LEGENDARY],
	8: [UnitsState.Rarity.COMMON, UnitsState.Rarity.UNCOMMON, UnitsState.Rarity.RARE, UnitsState.Rarity.LEGENDARY],
	9: [UnitsState.Rarity.COMMON, UnitsState.Rarity.UNCOMMON, UnitsState.Rarity.RARE, UnitsState.Rarity.LEGENDARY],
	10: [UnitsState.Rarity.COMMON, UnitsState.Rarity.UNCOMMON, UnitsState.Rarity.RARE, UnitsState.Rarity.LEGENDARY],
}


const ROLL_CHANCES = {
	1: [1],
	2: [1],
	3: [7.5, 2.5],
	4: [6.5, 3.0, 0.5],
	5: [5.0, 3.5, 1.5],
	6: [4.0, 4.0, 2.0],
	7: [2.75, 4.0, 3.24, 0.1],
	8: [2.5, 3.75, 3.45, 0.3],
	9: [1.75, 2.75, 4.5, 1.0],
	10: [1.0, 2.0, 4.5, 2.5],
}


@export_range(0, 99) var gold: int: set = _set_gold
@export_range(0, 99) var xp: int: set = _set_xp
@export_range(1, 10) var level: int: set = _set_level


func get_random_rarity_for_level() -> UnitsState.Rarity:
	var rng = RandomNumberGenerator.new()
	var array: Array = ROLL_RARITIES[level]
	var weights: PackedFloat32Array = PackedFloat32Array(ROLL_CHANCES[level])
	
	return array[rng.rand_weighted(weights)]


func get_current_xp_requirement() -> int:
	var next_level = clampi(level + 1, 1, 10)
	return XP_REQUIREMENTS[next_level]


func _set_gold(value: int) -> void:
	gold = value
	emit_changed()


func _set_xp(value: int) -> void:
	xp = value
	emit_changed()

	if level == 10:
		return

	var xp_requirement: int = get_current_xp_requirement()

	while level < 10 and xp >= xp_requirement:
		level += 1
		xp -= xp_requirement
		xp_requirement = get_current_xp_requirement()
		emit_changed()


func _set_level(value: int) -> void:
	level = value
	emit_changed()
