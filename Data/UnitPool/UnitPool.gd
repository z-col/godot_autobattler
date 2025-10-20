## UnitPool 类用于管理自走棋单位的池子，实现单位抽取、补充和稀有度筛选等逻辑。
#
# 功能：
# - 根据 available_units 初始化单位池（unit_pool），每个单位可有多个副本。
# - 支持按稀有度随机抽取单位，并从池中移除已抽取的单位。
# - 支持向池中补充单位（如合成后返还基础单位）。
#
# 属性说明：
# - available_units: 可用单位列表，配置每种单位及其数量。
# - unit_pool: 当前单位池，用于抽取和管理。
#
# 主要方法：
# - generate_unit_pool: 初始化单位池，将所有可用单位按数量加入池中。
# - get_random_unit_by_rarity: 按稀有度随机抽取单位，并移除。
# - add_unit: 向池中补充指定数量的单位。
class_name UnitPool extends Resource

##   可用单位列表，配置每种单位及其数量。
@export var available_units: Array[UnitsState]

##  当前单位池，用于抽取和管理。
var unit_pool: Array[UnitsState]

##  初始化单位池，将所有可用单位按数量加入池中。
func generate_unit_pool() -> void:
	unit_pool = []

	for unit: UnitsState in available_units:
		for i in unit.pool_count:
			unit_pool.append(unit)

##  按稀有度随机抽取单位，并移除。
func get_random_unit_by_rarity(rarity: UnitsState.Rarity) -> UnitsState:
	var units = unit_pool.filter(
		func(_units: UnitsState) -> bool:
		return _units.rarity == rarity
	)

	if units.is_empty():
		return null

	var picked_unit: UnitsState = units.pick_random()
	unit_pool.erase(picked_unit)

	return picked_unit

##  向池中补充指定数量的单位。
func add_unit(unit: UnitsState) -> void:
	var combined_count = unit.get_combined_unit_count()
	unit = unit.duplicate()
	unit.tier = 1

	for i in combined_count:
		unit_pool.append(unit)