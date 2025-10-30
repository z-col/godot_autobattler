# 单位合成器 - 负责处理自走棋游戏中三个相同单位合成一个更高等级单位的逻辑
class_name UnitCombiner extends Node

# 缓冲计时器 - 防止频繁触发合成检查，优化性能
@export var buffer_timer: Timer

# 待处理的合成更新队列计数 - 当有多个合成请求时进行排队
var queued_updates = 0
# 动画控制器 - 用于管理合成动画序列
var tween: Tween

# 节点准备就绪时调用
func _ready() -> void:
	# 连接缓冲计时器的超时信号到处理函数
	buffer_timer.timeout.connect(_on_buffer_timer_timeout)

# 外部调用的入口函数 - 当需要检查单位合成时调用此函数
func queue_unit_combination_update() -> void:
	# 启动缓冲计时器，延迟执行实际的合成检查
	buffer_timer.start()

# 主合成方法 - 按指定等级处理单位合成
func _update_unit_combinations(tier: int) -> void:
	# 步骤1: 按名称分组指定等级的所有单位
	var groups = _group_units_in_tier_by_name(tier)
	# 步骤2: 从分组中找出所有可以合成的三连组合
	var triplets: Array[Array] = _get_triplets_for_groups(groups)

	# 如果没有找到可以合成的组合，直接调用完成回调
	if triplets.is_empty():
		_on_units_combined(tier)
		return

	# 步骤3: 创建动画序列控制器
	tween = create_tween()

	# 步骤4: 为每个三连组合创建动画序列
	for combination in triplets:
		# 添加合成单位的回调，绑定三个单位参数
		tween.tween_callback(_combine_units.bind(combination[0], combination[1], combination[2]))
		# 添加动画间隔，确保每个合成动画有序执行
		tween.tween_interval(UnitAnimations.COMBINE_ANIM_LENGTH)
	
	# 步骤5: 当所有动画完成后，调用合成完成回调（一次性连接）
	tween.finished.connect(_on_units_combined.bind(tier), CONNECT_ONE_SHOT)

# 执行实际的单位合成操作
func _combine_units(unit1: Unit, unit2: Unit, unit3: Unit) -> void:
	# 将第一个单位的等级提升1级（保留这个单位）
	unit1.state.tier += 1
	# 从单位组中移除第二个单位（将被销毁）
	unit2.remove_from_group("units")
	# 从单位组中移除第三个单位（将被销毁）
	unit3.remove_from_group("units")
	# 播放第二个单位的合成动画，飞向第一个单位的位置
	unit2.animations.play_combine_animation(unit1.global_position + Arena.QUARTER_CELL_SIZE)
	# 播放第三个单位的合成动画，飞向第一个单位的位置
	unit3.animations.play_combine_animation(unit1.global_position + Arena.QUARTER_CELL_SIZE)

# 按名称分组指定等级的所有单位
func _group_units_in_tier_by_name(tier: int) -> Dictionary:
	# 获取场景中所有标记为"units"组的单位
	var units = get_tree().get_nodes_in_group("units")
	# 过滤出指定等级的单位
	var filtered_units = units.filter(
		# 使用匿名函数作为过滤条件
		func(unit: Unit):
			return unit.state.tier == tier
	)
	# 创建空字典用于存储分组结果
	var unit_groups = {}

	# 遍历过滤后的单位，按名称进行分组
	for unit: Unit in filtered_units:
		if unit_groups.has(unit.state.name):
			# 如果该名称已存在，将单位添加到对应数组中
			unit_groups[unit.state.name].append(unit)
		else:
			# 如果该名称不存在，创建新数组并添加单位
			unit_groups[unit.state.name] = [unit]

	# 返回分组结果：{单位名称: [单位1, 单位2, ...]}
	return unit_groups

# 从分组中找出所有可以合成的三连组合
func _get_triplets_for_groups(groups: Dictionary) -> Array[Array]:
	# 存储所有可以升级的组合
	var upgrades: Array[Array] = []

	# 遍历每个单位名称的分组
	for unit_name in groups:
		# 获取该名称的所有单位
		var current_units: Array = groups[unit_name]
		# 只要该分组还有至少3个单位，就继续找组合
		while current_units.size() >= 3:
			# 取前3个单位作为一个合成组合
			var combination = [current_units[0], current_units[1], current_units[2]]
			# 添加到升级列表中
			upgrades.append(combination)
			# 从当前分组中移除这3个单位，继续寻找剩余的组合
			current_units = current_units.slice(3)

	# 返回所有找到的三连组合
	return upgrades

# 缓冲计时器超时时的处理函数
func _on_buffer_timer_timeout() -> void:
	# 增加待处理更新计数
	queued_updates += 1

	# 如果没有正在运行的动画，立即开始处理1级单位的合成
	if not tween or not tween.is_running():
		_update_unit_combinations(1)

# 单位合成完成后的回调函数
func _on_units_combined(tier: int) -> void:
	if tier == 1:
		# 如果刚刚完成的是1级单位合成，继续检查2级单位的合成
		_update_unit_combinations(2)
	else:
		# 如果是2级单位合成完成，减少待处理计数
		queued_updates -= 1
		# 如果还有待处理的合成请求，继续处理1级单位合成
		if queued_updates >= 1:
			_update_unit_combinations(1)
