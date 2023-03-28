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


# Return the portion of the JSON data relating to the current stage of the quest
func get_current_stage_data() -> Dictionary:
	return data["stages"][stage]


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


# Checks if the prerequisites for the current quest stage are met
func is_quest_stage_complete() -> bool:
	var stage_data : Dictionary = data["stages"][stage]
	
	# First check for prerequisite items
	if stage_data.has("stage_cond_item"):
		if not InventoryManager.inventory_has_item(stage_data["stage_cond_item"]):
			return false
	
	# Second check relationship prerequisites
	if stage_data.has("stage_cond_rel"):
		for npc_id in stage_data["stage_cond_rel"].keys():
			var threshold = stage_data["stage_cond_rel"][npc_id]
			if RelationshipManager.get_relationship_value(npc_id) < threshold:
				return false
	
	return true
