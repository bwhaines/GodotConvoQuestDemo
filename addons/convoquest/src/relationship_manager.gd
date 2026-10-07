extends Node
## RelationshipManager tracks the relationship values between the player and NPCs.
##
## RelationshipManager is a singleton class that keeps track of the player's
## current relationship with each NPC as an integer value.

## A dictionary to store relationship values in the form 
## [code]"npc_id": <int>[/code]
var _relationships : Dictionary = {}


## Updates an NPC's relationship value, adding it if it doesn't already exist.
func update_relationship(npc_id:String, delta:int) -> void:
	if not _relationships.has(npc_id):
		_relationships[npc_id] = 0
	
	_relationships[npc_id] += delta


## Returns the current value of an NPC's relationship with Player.
func get_relationship_value(npc_id: String) -> int:
	if _relationships.has(npc_id):
		return _relationships[npc_id]
	else:
		_relationships[npc_id] = 0
		return 0


## Returns full dictionary of relationships, useful for for saving game data.
func get_relationships() -> Dictionary:
	return _relationships


## Replaces existing relationships dictionary, useful for loading game data.
func set_relationships(new_rels:Dictionary) -> void:
	_relationships = new_rels
