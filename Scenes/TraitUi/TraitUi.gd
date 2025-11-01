## TraitUi 类用于显示和管理自走棋中特性的UI界面。
#
# 特性UI是自走棋游戏中的重要界面元素，用于显示特性的图标、名称、
# 当前激活的单位数量以及特性等级信息。
#
# 功能：
# - 显示特性的图标和名称
# - 显示当前场上拥有该特性的单位数量
# - 显示特性等级要求和当前达到的等级
# - 根据特性是否激活调整UI透明度
#
# 属性说明：
# - trait_data: 要显示的特性数据
# - active: 特性是否激活的状态
# - trait_icon: 特性图标显示控件
# - active_units_label: 活跃单位数量显示标签
# - trait_level_labels: 特性等级富文本显示控件
# - trait_label: 特性名称显示标签
#
# 主要方法：
# - updata: 根据场上单位更新UI显示
# - _set_trait_data: 设置特性数据并更新UI
# - _set_active: 设置激活状态并调整透明度
class_name TraitUi extends PanelContainer


## 要显示的特性数据
## 当设置此属性时会自动调用 _set_trait_data 方法更新UI
@export var trait_data: Trait: set = _set_trait_data

## 特性是否激活的状态
## 当设置此属性时会自动调用 _set_active 方法调整UI透明度
@export var active: bool: set = _set_active


## 特性图标显示控件
@onready var trait_icon: TextureRect = %TraitIcon

## 活跃单位数量显示标签
## 显示当前场上拥有该特性的唯一单位数量
@onready var active_units_label: Label = %ActiveUnitsLabel

## 特性等级富文本显示控件
## 显示特性各等级要求和当前达到的等级（带高亮显示）
@onready var trait_level_labels: RichTextLabel = %TraitLevelLabels

## 特性名称显示标签
@onready var trait_label: Label = %TraitLabel


## 根据场上单位更新UI显示
##
## 此方法会根据传入的单位数组计算当前特性的状态，并更新所有相关UI元素：
## - 计算拥有该特性的唯一单位数量
## - 更新活跃单位数量显示
## - 更新特性等级富文本显示
## - 设置特性激活状态
##
## @param units: 场上所有单位的数组
func updata(units: Array[Unit]) -> void:
	# 获取拥有该特性的唯一单位数量
	var unique_units = trait_data.get_unique_unit_count(units)
	# 更新活跃单位数量显示
	active_units_label.text = str(unique_units)
	# 更新特性等级富文本显示（带高亮）
	trait_level_labels.text = trait_data.get_levels_bbcode(unique_units)
	# 设置特性激活状态
	active = trait_data.is_active(unique_units)


## 设置特性数据并更新UI
##
## 当 trait_data 属性被设置时自动调用此方法，用于：
## - 等待节点准备就绪（如果节点未就绪）
## - 更新特性图标显示
## - 更新特性名称显示
##
## @param value: 要设置的新特性数据
func _set_trait_data(value: Trait) -> void:
	# 如果节点未就绪，等待节点准备完成
	if not is_node_ready():
		await ready
	
	# 设置特性数据
	trait_data = value
	# 更新特性图标
	trait_icon.texture = trait_data.icon
	# 更新特性名称
	trait_label.text = trait_data.name


## 设置激活状态并调整透明度
##
## 当 active 属性被设置时自动调用此方法，用于：
## - 设置激活状态
## - 根据激活状态调整UI透明度（激活时完全不透明，非激活时半透明）
##
## @param value: 新的激活状态
func _set_active(value: bool) -> void:
	active = value

	# 根据激活状态调整透明度
	if active:
		# 激活状态：完全不透明
		modulate.a = 1.0
	else:
		# 非激活状态：半透明
		modulate.a = 0.5