class_name TierIcon extends TextureRect


const TIER_ICONS: Dictionary = {
	1: preload("res://assets/sprites/level1.png"),
	2: preload("res://assets/sprites/level2.png"),
	3: preload("res://assets/sprites/level3.png"),
}


@export var stats: UnitsState: set = set_stats


func set_stats(value: UnitsState) -> void:
	if stats == value:
		return

	stats = value

	if stats == null:
		return

	if not is_node_ready():
		await ready

	stats.changed.connect(_on_stats_changed)
	_on_stats_changed()


func _on_stats_changed() -> void:
	texture = TIER_ICONS[stats.tier]
