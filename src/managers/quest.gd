class_name Quest
extends Node


var data : Dictionary = {}
var id : String
var stage : int = 0


# Constructor, takes path to JSON file containing Quest data
func _init(path:String):
	
	# Read in file text and parse JSON into dictionary
	var full_path := "%s/%s" % [QuestManager.QUEST_FILES_PATH, path]
	var file := FileAccess.open(full_path, FileAccess.READ)
	var json := JSON.new()
	if json.parse(file.get_as_text()) == OK:
		if typeof(json.data) == TYPE_DICTIONARY:
			self.data = json.data
			self.id = self.data["id"]
	else:
		print("Error parsing json from %s: %s", path, json.get_error_message())


# Checks if all prerequisites for the current quest have been met
func is_quest_available() -> bool:
	# First check if prereq quests are all finished
	if data.has("prereq_quests"):
		for quest in data["prereq_quests"]:
			if not QuestManager.completed_quests.has(quest):
				return false
	
	# Second check if all prereq items have been collected
	if data.has("prereq_items"):
		for item in data["prereq_items"]:
			if not InventoryManager.inventory_has_item(item):
				return false
	
	# Third check if all relationship levels have been met
	if data.has("prereq_rels"):
		for npc_id in data["prereq_rels"].keys():
			var threshold = data["prereq_rels"][npc_id]
			if RelationshipManager.get_relationship_value(npc_id) < threshold:
				return false
	
	return true
