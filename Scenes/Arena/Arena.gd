# Arena 类是自走棋主场景的控制器，负责管理棋盘上的核心组件和单位的交互逻辑。
# 
# 功能：
# - 定义棋盘格子的基础尺寸常量，方便全局统一使用。
# - 持有并初始化 UnitMover（单位移动）、UnitSpawner（单位生成）、SellPortal（单位出售）等核心子节点。
# - 在场景加载时，建立信号连接，使新生成的单位能够自动绑定拖拽和出售等交互逻辑。
# 
# 工作流程：
# - 当 UnitSpawner 生成新单位时，会发出 unit_spawned 信号。
# - Arena 通过信号连接，让 UnitMover 和 SellPortal 自动为新单位设置相关功能，无需手动管理每个单位。
class_name Arena extends Node2D


const CELL_SIZE = Vector2(32, 32)
const HALF_CELL_SIZE = Vector2(16, 16)
const QUARTER_CELL_SIZE = Vector2(8, 8)


@onready var sell_portal: SellPortal = $SellPortal
@onready var unit_mover: UnitMover = $UnitMover
@onready var unit_spawner: UnitSpawner = $UnitSpawner
@onready var unit_combiner: UnitCombiner = $UnitCombiner
@onready var shop: Shop = %Shop

func _ready() -> void:
	unit_spawner.unit_spawned.connect(unit_mover.setup_unit)
	unit_spawner.unit_spawned.connect(sell_portal.setup_unit)
	unit_spawner.unit_spawned.connect(unit_combiner.queue_unit_combination_update.unbind(1))
	shop.unit_bought.connect(unit_spawner.spawn_unit)
