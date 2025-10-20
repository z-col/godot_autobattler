## Shop 控制器：管理商店界面中的卡牌抽取、购买与回收逻辑。
#
# 功能：
# - 使用 `unit_pool` 生成并维护可抽取单位的池子。
# - 根据玩家等级（`player_stats`）计算每张卡牌的稀有度并从 `unit_pool` 中抽取单位实例。
# - 在界面上生成若干 `UnitCard`，处理购买（`unit_bought` 信号）和未购买时的回收逻辑。
#
# 重要属性：
# - unit_pool: UnitPool 资源，负责单位池的生成与抽取。
# - player_stats: PlayerStats 资源，用于根据等级决定抽卡稀有度和显示购买状态。
# - shop_cards: 存放当前显示卡牌的容器节点。
#
# 主要方法：
# - _ready: 初始化 unit_pool 并创建初始卡牌。
# - _roll_units: 为预定数量（当前实现为 5）生成卡牌，每张卡牌根据等级随机分配稀有度并从池中取出对应单位。
# - _put_back_remaining_to_pool: 将未购买的卡牌对应的单位放回 unit_pool（用于重置/刷新商店）。
# - _on_unit_bought: 转发 UnitCard 的购买事件（发出 Shop 的 unit_bought 信号）。
# - _on_reroll_button_pressed: 将未购买卡牌放回池子然后重新抽取新卡牌。
#
# 注意事项：
# - `unit_pool.get_random_unit_by_rarity(rarity)` 可能返回 null（池中无该稀有度单位），在将其分配给卡牌前应检查空值以避免运行时错误。
# - `add_unit` 会根据单位的合成数（tier 与 combined_count）向池中添加多个副本，放回时会改变池总量。
# - 可以考虑在刷新时打印或检查池的长度以便调试：`unit_pool.unit_pool.size()`。

class_name Shop extends VBoxContainer


signal unit_bought(unit: UnitsState)


const UNIT_CARD = preload("res://Scenes/UnitCard/UnitCard.tscn")


@export var unit_pool: UnitPool
@export var player_stats: PlayerStats


@onready var shop_cards: VBoxContainer = %ShopCards


func _ready() -> void:
	unit_pool.generate_unit_pool()

	for child: Node in shop_cards.get_children():
		child.queue_free()
	
	_roll_units()


## _roll_units: 为预定数量（当前实现为 5）生成卡牌，每张卡牌根据等级随机分配稀有度并从池中取出对应单位。
func _roll_units() -> void:
	for i in 5:
		var rarity = player_stats.get_random_rarity_for_level()
		var new_card: UnitCard = UNIT_CARD.instantiate()
		new_card.unit_stats = unit_pool.get_random_unit_by_rarity(rarity)
		new_card.unit_bought.connect(_on_unit_bought)
		shop_cards.add_child(new_card)

## _put_back_remaining_to_pool: 将未购买的卡牌对应的单位放回 unit_pool（用于重置/刷新商店）。
func _put_back_remaining_to_pool() -> void:
	for unit_card: UnitCard in shop_cards.get_children():
		if not unit_card.bought:
			unit_pool.add_unit(unit_card.unit_stats)

		unit_card.queue_free()

## _on_unit_bought: 转发 UnitCard 的购买事件（发出 Shop 的 unit_bought 信号）。
func _on_unit_bought(unit: UnitsState) -> void:
	unit_bought.emit(unit)

## _on_reroll_button_pressed: 将未购买卡牌放回池子然后重新抽取新卡牌。
func _on_reroll_button_pressed() -> void:
	_put_back_remaining_to_pool()
	_roll_units()
