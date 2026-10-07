extends Node
## QuestManager handles the status and consequences of quests.
##
## QuestManager is a singleton class that organizes and handles signals for
## player quests, updates player relationships upon quest failure or success, 
## and organizes quests based on status.


## Signal emitted when a player begins a quest and it is added to the
## active_quests dictionary
signal quest_started()
## Signal emitted when a player successfully completes a quests requirements
signal quest_completed()
## Signal emitted when a player triggers a fail case for a quest
signal quest_failed()

## Path to the folder containing quest files
const QUEST_FILES_PATH : String = "res://quests"
## Path to the folder containing dialogue files
const CONVO_FILES_PATH : String = "res://dialogues"


## List of quests whose prerequisites are not met and cannot be started
var unavailable_quests : Dictionary = {}
## List whose prerequisites are met, but has not been started
var inactive_quests : Dictionary = {}
## List of active quests
var active_quests : Dictionary = {}
## List of successfully completed quests
var completed_quests: Dictionary = {}
## List of failed quests
var failed_quests: Dictionary = {}


func _ready():
	# Open and parse all quest data files
	for f in DirAccess.get_files_at(QUEST_FILES_PATH):
		var quest = Quest.new()
		quest.load_from_file(f)
		unavailable_quests[quest.id] = quest
	
	# Check for newly available quests after each conversation
	ConversationManager.conversation_ended.connect(_check_unavailable_quests)
	
	# Do initial check for available quests
	_check_unavailable_quests()


## Returns whether quest with given ID is in the active quests list.
func is_quest_active(id_str:String) -> bool:
	return active_quests.has(id_str)


## Advances one step in a quest or marks it completed if no more steps exist.
func advance_quest_step(id_str:String) -> void:
	# If the quest is already active...
	if active_quests.has(id_str):
		var q : Quest = active_quests[id_str]
		q.stage += 1
		# If no more stages left, mark the quest as completed
		if q.stage >= q.data["stages"].size():
			mark_complete(id_str)
		else:
			_add_quest_step_convos(q)
	
	# If the quest is just starting...
	elif inactive_quests.has(id_str):
		var q : Quest = inactive_quests[id_str]
		begin_quest(id_str)
		_add_quest_step_convos(q)
	
	# Error
	else:
		print("Given quest %s cannot proceed!" % id_str)


## Gets the correct conversation to display for a given quest.
func get_quest_step_convo(char_id:String, quest_str:String) -> String:
	var q : Quest
	
	# If the quest isn't active, return the start conversation
	if inactive_quests.has(quest_str):
		q = inactive_quests[quest_str]
		return "%s/%s.json" % [CONVO_FILES_PATH, q.data["start_convo"]]
	

	if active_quests.has(quest_str):
		q = active_quests[quest_str]
		var stage_data := q.get_current_stage_data()
		
		# First see if the char_id is the stage_gate (will advance the quest) or
		# the fail_gate (will fail the quest)
		if stage_data.has("fail_gate") and stage_data["fail_gate"] == char_id:
			return "%s/%s.json" % [CONVO_FILES_PATH, stage_data["fail_convo"]]
		
		# If quest is active, return either the pass or stop convo depending on
		# whether the current stage's prerequisites are met
		if q.is_quest_stage_complete():
			return "%s/%s.json" % [CONVO_FILES_PATH, stage_data["pass_convo"]]
		else:
			return "%s/%s.json" % [CONVO_FILES_PATH, stage_data["stop_convo"]]
	
	# If we get here, something is wrong!
	print("Error: get_quest_step_convo failed for %s" % quest_str)
	return ""


## Puts quest in active list and emit signal and prep failure conditions.
func begin_quest(id_str:String) -> void:
	active_quests[id_str] = inactive_quests[id_str]
	inactive_quests.erase(id_str)
	quest_started.emit()


## Moves quest from active to completed, emits the signal quest_completed, 
## updates relationship values, and updates conversation queues.
func mark_complete(id_str:String) -> void:
	var quest : Quest = active_quests[id_str]
	
	completed_quests[id_str] = quest
	active_quests.erase(id_str)
	quest_completed.emit()
	
	if quest.data.has("reward_rel_change"):
		RelationshipManager.update_relationship(
				quest.data["giver"],
				quest.data["reward_rel_change"])
	
	ConversationManager.remove_quest_convos(id_str)
	_check_unavailable_quests()


## Moves quest from active to failed, emits the signal quest_failed, updates
## relationship values, and updates conversation queues.
func mark_failed(id_str:String) -> void:
	var quest : Quest = active_quests[id_str]
	
	failed_quests[id_str] = quest
	active_quests.erase(id_str)
	quest_failed.emit()
	
	if quest.data.has("failure_rel_change"):
		RelationshipManager.update_relationship(
				quest.data["giver"],
				quest.data["failure_rel_change"])
	
	ConversationManager.remove_quest_convos(id_str)
	_check_unavailable_quests()


# Checks all quests in the unavailable list to see if any's prerequisites have
# been met so the quest can be moved to the inactive list.
func _check_unavailable_quests() -> void:
	for q in unavailable_quests.values():
		if q.is_quest_available():
			_move_quest_to_inactive(q.id)
			# If a quest doesn't have a giver, start it immediately
			if q.data["giver"] == "null":
				advance_quest_step(q.id)


# Adds quest ID to stage_gate character's convo queue, and to fail_gate char's 
# queue if there is one.
func _add_quest_step_convos(quest:Quest) -> void:
	var stage_data := quest.get_current_stage_data()
	
	if stage_data.has("stage_gate"):
		ConversationManager.char_queue_push(stage_data["stage_gate"], quest.id)
	
	if stage_data.has("fail_gate"):
		ConversationManager.char_queue_push(stage_data["fail_gate"], quest.id)


# Moves the quest from the unavailable list to the inactive list and adds the
# start convo to relevant character convo queue.
func _move_quest_to_inactive(id_str:String) -> void:
	inactive_quests[id_str] = unavailable_quests[id_str]
	unavailable_quests.erase(id_str)
	
	# Add start convo to the relevant character convo queue, if it exists
	var q : Quest = inactive_quests[id_str]
	if q.data["giver"] != "null":
		ConversationManager.char_queue_push(
				q.data["giver"], 
				id_str)
