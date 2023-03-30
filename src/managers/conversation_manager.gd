extends Node
# ConversationManager is a singleton class that manages what conversations will
# appear when the player interacts with an NPC.  It also emits signals that are
# defined in the conversation JSON files.


signal conversation_started
signal conversation_ended


var current_convo := {}
var current_line := 0
# Dictionary containing each characters list of quests that they will discuss
var _convo_queues : Dictionary = {
	"orange": [],
	"purple": [],
	"green": []
}


# Load conversation information from a given file and display it in a dialog
func load_conversation(filepath:String):
	# Load data from given conversation file
	var json = JSON.new()
	var file = FileAccess.open(filepath, FileAccess.READ)
	var err := json.parse(file.get_as_text())
	
	# Ensure read data is correct
	if err == OK:
		if typeof(json.data) == TYPE_DICTIONARY:
			current_convo = json.data
			current_line = -1
			conversation_started.emit()
	else:
		print("Error parsing json from %s: %s" % 
				[filepath, json.get_error_message()])


# Load the relevant convo for the first quest in the given character's queue
func char_queue_pop(char_id:String) -> bool :
	if _convo_queues[char_id].is_empty():
		return false
	else:
		var convo : String = QuestManager.get_quest_step_convo(
				char_id,
				_convo_queues[char_id].pop_front())
		if convo == "":
			return false
		else:
			load_conversation(convo)
			return true


# Add a given quest id to the character's queue
func char_queue_push(char_id:String, quest_id:String) -> void :
	# Add character ID to queue list if it doesn't already exist
	if not _convo_queues.has(char_id):
		_convo_queues[char_id] = []
	
	# Only add id if it's not already there
	if not _convo_queues[char_id].has(quest_id):
		_convo_queues[char_id].push_back(quest_id)


# Return the next line info of the conversation, or an empty dictionary if the
# conversation has ended
func advance_line() -> Dictionary:
	# Increment the conversation line counter and check if convo is over
	current_line += 1
	if current_line >= current_convo["lines"].size():
		_clear_dialog()
		return {}
	
	# Get the next line of the current conversation
	var new_line : Dictionary = current_convo["lines"][current_line]
	
	# Handle any other attributes in new_line
	if new_line.has("give_item"):
		InventoryManager.change_amount_in_inventory(new_line["quest_step"], 1)
	
	if new_line.has("rel_change"):
		for npc in new_line["rel_change"].keys():
			var value = new_line["rel_change"][npc]
			RelationshipManager.update_relationship(npc, value)
	
	if new_line.has("quest_step"):
		QuestManager.advance_quest_step(new_line["quest_step"])
	
	if new_line.has("quest_fail"):
		QuestManager.mark_failed(new_line["quest_fail"])
	
	return new_line


# Remove any conversations pertaining to given quest from all convo queues
func remove_quest_convos(id_str:String) -> void:
	for queue in _convo_queues.values():
		for convo in queue:
			if convo.contains(id_str):
				queue.erase(convo)


# Remove the conversation UI and reset "current_" vars
func _clear_dialog() -> void:
	current_convo = {}
	current_line = -1
	conversation_ended.emit()
