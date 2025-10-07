# SellPortal 类用于实现单位出售的交互区域。
# 
# 功能：
# - 监听单位拖拽和快速出售操作，实现单位的出售和金币结算。
# - 高亮显示当前可出售单位，并展示其出售价值。
# - 通过与 PlayerStats 交互，完成金币的增加和单位的移除。
# 
# 属性说明：
# - player_stats: 玩家属性对象，用于管理金币等数据。
# - outline_highlighter: 区域高亮节点，提示当前可出售单位。
# - gold, gold_label: 用于显示单位出售获得的金币数。
# - current_unit: 当前进入出售区域的单位。
# 
# 主要方法：
# - setup_unit: 为单位绑定拖拽和快速出售信号。
# - _sell_unit: 执行单位出售逻辑，增加金币并移除单位。
# - _on_unit_dropped: 检查单位是否在出售区域释放，触发出售。
# - _on_area_entered/_on_area_exited: 处理单位进入/离开出售区域的高亮和金币展示。
class_name SellPortal extends Area2D

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
	print(player_stats.gold)
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
