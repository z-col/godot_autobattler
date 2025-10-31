## UnitsState 类用于描述自走棋单位的基础属性和状态。
# 
# 功能：
# - 存储单位的名称、稀有度、价格、星级、皮肤坐标等数据。
# - 提供单位合成数量和出售价值的计算方法。
# - 支持星级变更并通过信号通知外部。
# 
# 属性说明：
# - name: 单位名称。
# - rarity: 单位稀有度（枚举类型）。
# - gold_cost: 单位基础价格。
# - tier: 单位星级（1~3星）。
# - skin_coordinates: 单位皮肤在图集中的坐标。
# - pool_count: 单位在池中的数量。
# 
# 主要方法：
# - get_combined_unit_count: 计算合成当前星级单位所需的基础单位数量。
# - get_gold_value: 计算单位出售时获得的金币数。
# - _set_tier: 设置星级并发出变更信号。
# - _to_string: 返回单位名称。
class_name UnitsState extends Resource


enum Rarity {COMMON, UNCOMMON, RARE, LEGENDARY}


const RARITY_COLORS = {
	Rarity.COMMON: Color("124a2e"),
	Rarity.UNCOMMON: Color("1c527c"),
	Rarity.RARE: Color("ab0979"),
	Rarity.LEGENDARY: Color("ea940b"),
}


@export var name: String

@export_category("Data") ## 单位名称。
@export var rarity: Rarity ## 单位稀有度（枚举类型）。
@export var gold_cost: int = 1 ## 单位基础价格。
@export_range(1, 3) var tier: int = 1: set = _set_tier ## 单位星级（1~3星）。
@export var traits: Array[Trait]
@export var pool_count: int = 5 ## 单位在池中的数量。

@export_category("Visuals")
@export var skin_coordinates: Vector2i ## 单位皮肤在图集中的坐标。

func get_combined_unit_count() -> int:
	return 3 ** (tier - 1)


func get_gold_value() -> int:
	return gold_cost * get_combined_unit_count()


func _set_tier(value: int) -> void:
	tier = value
	emit_changed()


func _to_string() -> String:
	return name