## UnitCard 类用于实现商店单位卡牌的交互和展示。
# 
# 功能：
# - 展示单位的名称、稀有度、价格、图标等信息。
# - 根据玩家金币自动更新卡牌的可购买状态和视觉效果。
# - 处理单位购买逻辑，扣除金币并发出购买信号。
# - 支持鼠标悬停高亮、已购买状态显示等交互。
# 
# 属性说明：
# - player_stats: 玩家属性对象，用于获取和修改金币。
# - unit_stats: 单位属性对象，包含单位的基础数据。
# - bought: 是否已购买。
# - border_color: 卡牌边框颜色，根据单位稀有度自动设置。
# - 其他 UI 相关节点：traits、unit_name、gold_cost、unit_icon 等。
# 
# 主要方法：
# - _set_unit_stats: 初始化和刷新单位卡牌的显示内容。
# - _on_player_stats_changed: 根据金币数量更新卡牌状态和透明度。
# - _on_pressed: 响应卡牌点击事件，完成购买逻辑。
# - _on_mouse_entered/_on_mouse_exited: 处理鼠标悬停高亮效果。
class_name UnitCard extends Button


signal unit_bought(unit: UnitsState)


const HOVER_BORDER_COLOR = Color("fafa82")


@export var player_stats: PlayerStats
@export var unit_stats: UnitsState: set = _set_unit_stats

@onready var traits: Label = %Traits
@onready var bttom: Panel = %Bttom
@onready var unit_name: Label = %UnitName
@onready var gold_cost: Label = %GoldCost
@onready var border: Panel = %Border
@onready var unit_icon: TextureRect = %UnitIcon
@onready var empty_place_holder: Panel = %EmptyPlaceHolder
@onready var border_sb: StyleBoxFlat = border.get_theme_stylebox("panel")
@onready var bottom_sb: StyleBoxFlat = bttom.get_theme_stylebox("panel")


var bought = false
var border_color: Color


func _ready() -> void:
	player_stats.changed.connect(_on_player_stats_changed)
	_on_player_stats_changed()

func _set_unit_stats(value: UnitsState) -> void:
	unit_stats = value

	if not is_node_ready():
		await ready

	if not unit_stats:
		empty_place_holder.show()
		disabled = true
		bought = true
		return
	
	border_color = UnitsState.RARITY_COLORS[unit_stats.rarity]
	border_sb.border_color = border_color
	bottom_sb.bg_color = border_color
	traits.text = "\n".join(Trait.get_trait_names(unit_stats.traits))
	unit_name.text = unit_stats.name
	gold_cost.text = str(unit_stats.gold_cost)
	unit_icon.texture.region.position = Vector2(unit_stats.skin_coordinates) * Arena.CELL_SIZE

func _on_player_stats_changed() -> void:
	if not unit_stats:
		return

	var has_enough_gold = player_stats.gold >= unit_stats.gold_cost
	disabled = not has_enough_gold

	if has_enough_gold or bought:
		modulate = Color(Color.WHITE, 1.0)
	else:
		modulate = Color(Color.WHITE, 0.5)


func _on_pressed() -> void:
	if bought:
		return
	
	bought = true
	empty_place_holder.show()
	player_stats.gold -= unit_stats.gold_cost
	unit_bought.emit(unit_stats)


func _on_mouse_exited() -> void:
	border_sb.border_color = border_color
	

func _on_mouse_entered() -> void:
	if not disabled:
		border_sb.border_color = HOVER_BORDER_COLOR
