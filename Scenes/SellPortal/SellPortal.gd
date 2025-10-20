## SellPortal：单位出售区 (Area2D)
#
# 描述：
# SellPortal 提供一个出售交互区域，玩家可以将单位拖放到此区域进行出售，或使用单位的快速出售触发器立即出售。
# 出售会给玩家增加金币，并（可选地）将单位状态回收到 `UnitPool` 中以供后续抽卡使用。
#
# 重要信号/连接：
# - 本类不会主动发出信号；它通过 `setup_unit(unit)` 为每个单位绑定两个事件：
#   `unit.drag_and_drop.dropped` -> `_on_unit_dropped`（拖放释放）
#   `unit.quick_sell_pressed` -> `_sell_unit`（快速出售按键）
#
# 主要属性：
# - unit_pool (可选)：`UnitPool` 资源，若存在，出售时会调用 `unit_pool.add_unit(unit.state)` 将单位回收至池中。
# - player_stats：玩家数据（金币/经验/等级），出售时会修改 `player_stats.gold`。
# - outline_highlighter：用于在单位进入出售区时突出显示的节点。
# - gold / gold_label：UI 节点，用于展示被出售单位可获得的金币数。
#
# 主要方法：
# - setup_unit(unit): 为单位绑定出售相关信号，使该单位进入可售状态。
# - _sell_unit(unit): 执行出售：
#     1) 将单位的金币加到 `player_stats.gold`。
#     2) 若 `unit_pool` 存在且 `unit.state` 有效，则将单位状态返回至池子（`unit_pool.add_unit(unit.state)`）。
#     3) 从场景中移除单位节点（`unit.queue_free()`）。
# - _on_unit_dropped(starting_position, unit): 当单位在出售区域放手时，如果该单位正位于出售区（通过 `current_unit` 确认），则出售。此函数用于区分拖放取消与真正的出售动作。
# - _on_area_entered/_on_area_exited(unit): 维护 `current_unit`、UI 高亮和金币提示的显示与隐藏。
#
# 使用示例：
# - 在场景加载时（例如 Arena._ready），遍历已存在的单位并调用 `sell_portal.setup_unit(unit)`。
# - 当 UnitSpawner 生成新单位时，通过信号连接让 SellPortal 自动为新单位绑定出售处理。
#
# 常见边界情况与建议：
# - 在调用 `unit_pool.add_unit(unit.state)` 前，先确认 `unit.state != null`，以避免将空数据加入池中。
# - `add_unit` 可能会根据单位的合成规则向池中添加多个副本（例如将一个 2 星单位分解成 3 个 1 星单位），因此出售会显著改变池的条目数。
# - 出售时调用 `queue_free()` 会立即从场景中移除节点，确保 UI 与池状态的一致性以避免重复或丢失单位数据。
class_name SellPortal extends Area2D

@export var unit_pool: UnitPool
@export var player_stats: PlayerStats


@onready var outline_highlighter: Node = $OutlineHighlighter
@onready var gold: HBoxContainer = %Gold
@onready var gold_label: Label = $Gold/GoldLabel


var current_unit: Unit


func _ready() -> void:
	var units = get_tree().get_nodes_in_group("units")
	for unit: Unit in units:
		setup_unit(unit)


func setup_unit(unit: Unit) -> void:
	unit.drag_and_drop.dropped.connect(_on_unit_dropped.bind(unit))
	unit.quick_sell_pressed.connect(_sell_unit.bind(unit))


func _sell_unit(unit: Unit) -> void:
	player_stats.gold += unit.state.get_gold_value()
	unit_pool.add_unit(unit.state)
	unit.queue_free()

func _on_unit_dropped(_starting_position: Vector2, unit: Unit) -> void:
	if unit and unit == current_unit:
		_sell_unit(unit)
		unit.queue_free()
		

func _on_area_entered(unit: Unit) -> void:
	current_unit = unit
	outline_highlighter.highlight()
	gold_label.text = str(unit.state.get_gold_value())
	gold.show()

func _on_area_exited(unit: Unit) -> void:
	if unit and unit == current_unit:
		current_unit = null

	outline_highlighter.clear_highlight()
	gold.hide()
