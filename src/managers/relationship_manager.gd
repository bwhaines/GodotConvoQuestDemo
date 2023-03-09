extends Node


var _relationships : Dictionary = {}


# Update an NPC's relationship value, adding it if it doesn't already exist
func update_relationship(npc_id:String, delta:int) -> void:
	if not _relationships.has(npc_id):
		_relationships[npc_id] = 0
	
	_relationships[npc_id] += delta


# Return the current value of an NPC's relationship with Player
func get_relationship_value(npc_id: String) -> int:
	if _relationships.has(npc_id):
		return _relationships[npc_id]
	else:
		_relationships[npc_id] = 0
		return 0
