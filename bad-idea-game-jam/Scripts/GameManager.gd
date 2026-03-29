extends Node

var last_checkpoint_pos: Vector2 = Vector2.ZERO
var tutorials_seen: Array = []
var unlocked_abilities = {
	"can_jump": false,
	"can_double_jump": false,
	"can_dash": false,
	"can_ledge_grab": false
	}
