# Unit 类用于表示自走棋中的单个单位（棋子），包含其属性、状态和相关逻辑。
# 
# 功能：
# - 存储单位的基础数据，如名称、稀有度、价格、星级、皮肤坐标等。
# - 提供单位合成、出售等相关计算方法。
# - 通过与 UnitsState 交互，管理单位的升级、合成和价值。
# - 支持与拖拽、移动、出售等系统的集成。
# 
# 常见属性：
# - name: 单位名称。
# - rarity: 单位稀有度。
# - gold_cost: 单位价格。
# - tier: 单位星级。
# - skin_coordinates: 单位皮肤坐标。
# 
# 常见方法：
# - get_combined_unit_count: 计算合成当前星级单位所需的基础单位数量。
# - get_gold_value: 计算单位出售时获得的金币数。
# - 其他与单位状态相关的方法。
# 
# 该类通常作为场景中的棋子节点实例，参与棋盘上的各种交互。
# 具体实现可根据实际项目需求扩展。
@tool
class_name Unit extends Area2D


signal quick_sell_pressed


@export var state: UnitsState: set = set_state


@onready var skin: Sprite2D = %Skin
@onready var health_bar: ProgressBar = $HealthBar
@onready var mana_bar: ProgressBar = $ManaBar
@onready var tier_icon: TierIcon = $TierIcon
@onready var drag_and_drop: DragAndDrop = $DragAndDrop
@onready var velocity_based_rotation: VelocityBasedRotation = $VelocityBasedRotation
@onready var outline_highlighter: OutlineHighlighter = $OutlineHighlighter
@onready var animations: UnitAnimations = $UnitAnimations

var is_hovered: bool = false


func _ready() -> void:
	if not Engine.is_editor_hint():
		drag_and_drop.drag_started.connect(_on_drag_started)
		drag_and_drop.drag_canceled.connect(_on_drag_canceled)
		quick_sell_pressed.connect(func(): print("sell"))


func _input(event: InputEvent) -> void:
	if not is_hovered:
		return

	if event.is_action_pressed("quick_sell"):
		quick_sell_pressed.emit()


func set_state(value: UnitsState):
	state = value

	if value == null:
		return

	if not is_node_ready():
		await ready

	if not Engine.is_editor_hint():
		state = value.duplicate()

	skin.region_rect.position = Vector2(state.skin_coordinates) * Arena.CELL_SIZE
	tier_icon.stats = state


func reset_after_dragging(starting_position: Vector2) -> void:
	velocity_based_rotation.enabled = false
	global_position = starting_position


func _on_drag_started() -> void:
	velocity_based_rotation.enabled = true


func _on_drag_canceled(starting_position: Vector2) -> void:
	reset_after_dragging(starting_position)


func _on_mouse_entered() -> void:
	if drag_and_drop.dragging:
		return

	is_hovered = true
	outline_highlighter.highlight()
	z_index = 1


func _on_mouse_exited() -> void:
	if drag_and_drop.dragging:
		return
	
	is_hovered = false
	outline_highlighter.clear_highlight()
	z_index = 0
