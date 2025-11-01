## Trait 类用于定义和管理单位的特性系统。
#
# 特性是自走棋游戏中的核心机制，每个单位可以拥有多个特性，特性根据场上
# 相同特性的单位数量激活不同的等级效果。
#
# 功能：
# - 定义特性的名称、图标、描述和等级系统
# - 计算场上特定特性的单位数量
# - 判断特性是否激活以及当前等级
# - 生成特性等级的富文本显示
#
# 属性说明：
# - name: 特性名称
# - icon: 特性图标纹理
# - description: 特性描述（支持多行文本）
# - levels: 特性最大等级（1-5级）
# - unit_requirements: 各等级所需的单位数量数组
# - unit_modifiers: 各等级对应的单位修改器场景
#
# 主要方法：
# - get_unique_unit_count: 获取场上拥有该特性的唯一单位数量
# - is_active: 判断特性是否激活（达到最低要求）
# - get_levels_bbcode: 生成带高亮显示的等级富文本
# - get_unique_traits_for_units: 获取单位数组中所有唯一特性
# - get_trait_names: 获取特性数组中的所有特性名称
class_name Trait extends Resource


## 高亮颜色代码，用于在等级显示中突出当前达到的等级
const HIGHLIGHT_COLOR_CODE: String = "fafa82"


## 特性名称
@export var name: String

## 特性图标纹理
@export var icon: Texture

## 特性描述，支持多行文本
@export_multiline var description: String

## 特性最大等级，范围1-5级
@export_range(1, 5) var levels: int

## 各等级所需的单位数量数组
## 例如：[2, 4, 6] 表示需要2个单位激活1级，4个单位激活2级，6个单位激活3级
@export var unit_requirements: Array[int]

## 各等级对应的单位修改器场景数组
## 每个等级对应一个修改器场景，用于应用该等级的效果
@export var unit_modifiers: Array[PackedScene]


## 获取场上拥有该特性的唯一单位数量
##
## 此方法会过滤出所有拥有该特性的单位，然后统计不同名称的单位数量，
## 避免重复计算相同名称的单位。
##
## @param units: 场上所有单位的数组
## @return: 拥有该特性的唯一单位数量
func get_unique_unit_count(units: Array[Unit]) -> int:
	# 过滤出所有拥有该特性的单位
	units = units.filter(
		func(unit: Unit):
			return unit.state.traits.has(self)
	)

	# 统计不同名称的单位数量
	var unique_units: Array[String] = []
	for unit: Unit in units:
		if not unique_units.has(unit.stats.name):
			unique_units.append(unit.state.name)

	return unique_units.size()


## 判断特性是否激活
##
## 当场上拥有该特性的唯一单位数量达到最低要求时，特性激活。
##
## @param unique_unit_count: 场上拥有该特性的唯一单位数量
## @return: 如果特性激活返回true，否则返回false
func is_active(unique_unit_count: int) -> bool:
	return unique_unit_count >= unit_requirements[0]


## 获取单位数组中所有唯一特性
##
## 静态方法，用于从单位数组中提取所有不重复的特性。
##
## @param units: 单位数组
## @return: 包含所有唯一特性的数组
static func get_unique_traits_for_units(units: Array[Unit]) -> Array[Trait]:
	var traits: Array[Trait] = []
	
	# 遍历所有单位及其特性，收集不重复的特性
	for unit: Unit in units:
		for trait_data: Trait in unit.state.traits:
			if not traits.has(trait_data):
				traits.append(trait_data)

	return traits


## 获取特性数组中的所有特性名称
##
## 静态方法，用于从特性数组中提取所有特性的名称。
##
## @param traits: 特性数组
## @return: 包含所有特性名称的字符串数组
static func get_trait_names(traits: Array[Trait]) -> PackedStringArray:
	var trait_names: PackedStringArray = []

	# 遍历特性数组，收集所有特性名称
	for current_trait in traits:
		trait_names.append(current_trait.name)

	return trait_names
	
	
## 生成带高亮显示的等级富文本
##
## 根据当前单位数量生成特性等级的富文本显示，当前达到的等级会高亮显示。
## 例如：当有3个单位时，对于要求[2,4,6]的特性会显示 "2/[color=#fafa82]4[/color]/6"
##
## @param unit_count: 当前场上拥有该特性的单位数量
## @return: 格式化的等级富文本字符串
func get_levels_bbcode(unit_count: int) -> String:
	var code: PackedStringArray = []
	
	# 找出所有已达到的等级要求
	var reached_level = unit_requirements.filter(
		func(requirement: int):
			return unit_count >= requirement
	)

	# 为每个等级生成对应的富文本
	for i: int in levels:
		if i == (reached_level.size() - 1):
			# 当前达到的等级使用高亮颜色
			code.append("[color=#%s]%s[/color]" % [HIGHLIGHT_COLOR_CODE, unit_requirements[i]])
		else:
			# 其他等级使用普通显示
			code.append(str(unit_requirements[i]))

	return "/".join(code)
