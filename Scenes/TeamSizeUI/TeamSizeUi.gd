## TeamSizeUi 类用于显示队伍规模信息和单位数量限制
#
# 功能：
# - 实时显示当前已使用的单位数量和等级限制
# - 当单位数量超过等级限制时显示警告图标
# - 监听玩家状态和竞技场网格的变化并自动更新显示
#
# 属性：
# - player_stats: 玩家状态数据，包含等级信息
# - arena_grid: 竞技场网格，用于获取单位数量
# - unit_counter: 单位计数器标签
# - too_many_units_icon: 单位超限警告图标
#
# 方法：
# - _ready: 初始化信号连接和显示
# - _update: 更新单位计数器和警告图标显示
class_name TeamSizeUi extends PanelContainer


# 玩家状态数据，包含等级信息用于计算单位数量限制
@export var player_stats: PlayerStats
# 竞技场网格，用于获取当前已放置的单位数量
@export var arena_grid: UnitGrid


# 单位计数器标签，显示"当前单位数/等级限制"格式
@onready var unit_counter: Label = %UnitCounter
# 单位超限警告图标，当单位数量超过等级限制时显示
@onready var too_many_units_icon: TextureRect = %TooManyUnitsIcon


# 节点准备就绪时调用，连接信号并初始化显示
func _ready() -> void:
	player_stats.changed.connect(_update)
	arena_grid.unit_grid_changed.connect(_update)
	_update()


## 更新单位计数器和警告图标显示
func _update() -> void:
	var units_used = arena_grid.get_all_units().size()
	print("level : ", player_stats.level)
	unit_counter.text = "%s/%s" % [units_used, player_stats.level]
	too_many_units_icon.visible = units_used > player_stats.level
