## UnitCard 类用于实现商店单位卡牌的交互和展示。
#
# 功能：
# - 展示单位的名称、稀有度、价格、图标和特性信息。
# - 根据玩家金币自动更新卡牌的可购买状态和视觉效果。
# - 处理单位购买逻辑，扣除金币并发出购买信号。
# - 支持鼠标悬停高亮、已购买状态显示等交互效果。
# - 根据单位稀有度自动设置卡牌边框颜色。
#
# 属性说明：
# - player_stats: 玩家属性对象，用于获取和修改金币。
# - unit_stats: 单位属性对象，包含单位的基础数据。
# - bought: 是否已购买，防止重复购买。
# - border_color: 卡牌边框颜色，根据单位稀有度自动设置。
# - HOVER_BORDER_COLOR: 鼠标悬停时的边框高亮颜色。
#
# UI 节点说明：
# - traits: 显示单位特性的标签
# - bttom: 卡牌底部面板
# - unit_name: 显示单位名称的标签
# - gold_cost: 显示单位价格的标签
# - border: 卡牌边框面板
# - unit_icon: 显示单位图标的纹理矩形
# - empty_place_holder: 空卡牌占位符面板
# - border_sb: 边框样式框
# - bottom_sb: 底部样式框
#
# 主要方法：
# - _set_unit_stats: 初始化和刷新单位卡牌的显示内容。
# - _on_player_stats_changed: 根据金币数量更新卡牌状态和透明度。
# - _on_pressed: 响应卡牌点击事件，完成购买逻辑。
# - _on_mouse_entered/_on_mouse_exited: 处理鼠标悬停高亮效果。
class_name UnitCard extends Button


## 单位购买信号
# 当单位被成功购买时发出，携带被购买的单位数据
signal unit_bought(unit: UnitsState)


## 鼠标悬停时的边框高亮颜色
const HOVER_BORDER_COLOR = Color("fafa82")


## 玩家属性对象，用于获取和修改金币
@export var player_stats: PlayerStats

## 单位属性对象，包含单位的基础数据，设置时会自动调用 _set_unit_stats 方法
@export var unit_stats: UnitsState: set = _set_unit_stats

## 显示单位特性的标签
@onready var traits: Label = %Traits

## 卡牌底部面板
@onready var bttom: Panel = %Bttom

## 显示单位名称的标签
@onready var unit_name: Label = %UnitName

## 显示单位价格的标签
@onready var gold_cost: Label = %GoldCost

## 卡牌边框面板
@onready var border: Panel = %Border

## 显示单位图标的纹理矩形
@onready var unit_icon: TextureRect = %UnitIcon

## 空卡牌占位符面板，当卡牌为空时显示
@onready var empty_place_holder: Panel = %EmptyPlaceHolder

## 边框样式框，用于动态修改边框颜色
@onready var border_sb: StyleBoxFlat = border.get_theme_stylebox("panel")

## 底部样式框，用于动态修改底部颜色
@onready var bottom_sb: StyleBoxFlat = bttom.get_theme_stylebox("panel")


## 是否已购买，防止重复购买
var bought = false

## 卡牌边框颜色，根据单位稀有度自动设置
var border_color: Color


## 节点准备就绪时调用
# 连接玩家属性变化信号，并初始化卡牌状态
func _ready() -> void:
	player_stats.changed.connect(_on_player_stats_changed)
	_on_player_stats_changed()

## 设置单位属性并更新卡牌显示
#
# 当 unit_stats 属性被设置时自动调用，用于初始化或更新卡牌的显示内容。
# 包括设置边框颜色、特性文本、单位名称、价格和图标位置。
#
# @param value: 新的单位属性对象
func _set_unit_stats(value: UnitsState) -> void:
	unit_stats = value

	# 确保节点已准备就绪
	if not is_node_ready():
		await ready

	# 如果单位属性为空，显示空卡牌状态
	if not unit_stats:
		empty_place_holder.show()
		disabled = true
		bought = true
		return
	
	# 根据单位稀有度设置边框颜色
	border_color = UnitsState.RARITY_COLORS[unit_stats.rarity]
	border_sb.border_color = border_color
	bottom_sb.bg_color = border_color
	
	# 设置特性文本（每行显示一个特性）
	traits.text = "\n".join(Trait.get_trait_names(unit_stats.traits))
	
	# 设置单位名称和价格
	unit_name.text = unit_stats.name
	gold_cost.text = str(unit_stats.gold_cost)
	
	# 设置单位图标位置（基于精灵图集坐标）
	unit_icon.texture.region.position = Vector2(unit_stats.skin_coordinates) * Arena.CELL_SIZE

## 玩家属性变化时的回调函数
#
# 当玩家金币数量变化时自动调用，用于更新卡牌的可购买状态和视觉效果。
# 如果金币不足且未购买，卡牌会变为半透明并禁用。
func _on_player_stats_changed() -> void:
	if not unit_stats:
		return

	# 检查玩家是否有足够的金币购买该单位
	var has_enough_gold = player_stats.gold >= unit_stats.gold_cost
	disabled = not has_enough_gold

	# 根据购买状态和金币数量设置透明度
	if has_enough_gold or bought:
		modulate = Color(Color.WHITE, 1.0) # 完全可见
	else:
		modulate = Color(Color.WHITE, 0.5) # 半透明


## 卡牌点击事件处理
#
# 当玩家点击卡牌时调用，处理单位购买逻辑。
# 包括标记已购买状态、扣除金币、显示空占位符和发出购买信号。
func _on_pressed() -> void:
	# 防止重复购买
	if bought:
		return
	
	# 标记为已购买
	bought = true
	
	# 显示空占位符
	empty_place_holder.show()
	
	# 扣除玩家金币
	player_stats.gold -= unit_stats.gold_cost
	
	# 发出单位购买信号
	unit_bought.emit(unit_stats)


## 鼠标离开卡牌时的回调函数
#
# 恢复卡牌边框颜色为原始稀有度颜色
func _on_mouse_exited() -> void:
	border_sb.border_color = border_color
	

## 鼠标进入卡牌时的回调函数
#
# 当鼠标悬停在可购买的卡牌上时，将边框颜色改为高亮颜色
func _on_mouse_entered() -> void:
	if not disabled:
		border_sb.border_color = HOVER_BORDER_COLOR
