extends Node
# QuestManager is a singleton class that organizes and handles signals for
# player quests.


signal quest_started()
signal quest_completed()
signal quest_failed()

const QUEST_FILES_PATH : String = "res://quests"
const CONVO_FILES_PATH : String = "res://dialogues"


# List of quests whose prerequisites are not met
var unavailable_quests : Dictionary = {}
# List whose prerequisites are met, but has not started
var inactive_quests : Dictionary = {}
# List of active quests
var active_quests : Dictionary = {}
# List of completed quests
var completed_quests: Dictionary = {}
# List of failed quests
var failed_quests: Dictionary = {}


func _ready():
	# Open and parse all quest data files
	for f in DirAccess.get_files_at(QUEST_FILES_PATH):
		var quest = Quest.new(f)
		unavailable_quests[quest.id] = quest
	
	# Check for newly available quests after each conversation
	ConversationManager.conversation_ended.connect(_check_unavailable_quests)
	
	# Do initial check for available quests
	_check_unavailable_quests()


# Returns whether quest with given ID is in the active quests list
func is_quest_active(id_str:String) -> bool:
	return active_quests.has(id_str)


# Advance one step in a quest
func advance_quest_step(id_str:String) -> void:
	# If the quest is already active...
	if active_quests.has(id_str):
		var q : Quest = active_quests[id_str]
		q.stage += 1
		_add_quest_step_convos(id_str, q.stage)
		# If no more stages left, mark the quest as completed
		if q.stage >= q.data["stages"].size():
			mark_complete(id_str)
	
	# If the quest is just starting...
	elif inactive_quests.has(id_str):
		var q : Quest = inactive_quests[id_str]
		begin_quest(id_str)
		_add_quest_step_convos(id_str, q.stage)
	
	# Error
	else:
		print("Given quest %s cannot proceed!" % id_str)


# Put quest in active list and emit signal, prep failure conditions
func begin_quest(id_str:String) -> void:
	active_quests[id_str] = inactive_quests[id_str]
	inactive_quests.erase(id_str)
	quest_started.emit()
	
	# Move fail convo (if it exists) to relevant character convo queue
	var fail_convo = "%s/%s_fail.json" % [CONVO_FILES_PATH, id_str]
	if FileAccess.file_exists(fail_convo):
		var json = JSON.new()
		var file = FileAccess.open(fail_convo, FileAccess.READ)
		if json.parse(file.get_as_text()) == OK:
			var char_id : String = json.data["char_id"]
			ConversationManager.char_queue_push(char_id, fail_convo)
		else:
			print("Error parsing dialogue file %s" % fail_convo)


# Move quest from active to completed, emit signal, update relationships and
# conversation queues
func mark_complete(id_str:String) -> void:
	var quest : Quest = active_quests[id_str]
	
	completed_quests[id_str] = quest
	active_quests.erase(id_str)
	quest_completed.emit()
	
	RelationshipManager.update_relationship(
			quest.data["giver"],
			quest.data["reward_rel_change"])
	ConversationManager.remove_quest_convos(id_str)
	_check_unavailable_quests()


# Move quest from active to failed, emit signal, update relationships and
# conversation queues
func mark_failed(id_str:String) -> void:
	var quest : Quest = active_quests[id_str]
	
	failed_quests[id_str] = quest
	active_quests.erase(id_str)
	quest_failed.emit()
	
	RelationshipManager.update_relationship(
			quest.data["giver"],
			quest.data["failure_rel_change"])
	ConversationManager.remove_quest_convos(id_str)


# Check all quests in the unavailable list to see if prerequisites have been met
func _check_unavailable_quests() -> void:
	for q in unavailable_quests.values():
		if q.is_quest_available():
			_move_quest_to_inactive(q.id)


# Add any convos related to the given quest stage to the convo queues
func _add_quest_step_convos(id_str:String, step:int) -> bool:
	for f in DirAccess.get_files_at(CONVO_FILES_PATH):
		var file_prefix := "%s_s%02d" % [id_str, step]
		if f.contains(file_prefix):
			# Determine who to talk to, to initiate this convo
			var json = JSON.new()
			var filepath := "%s/%s" % [CONVO_FILES_PATH, f]
			var file = FileAccess.open(filepath, FileAccess.READ)
			if json.parse(file.get_as_text()) == OK:
				var char_id : String = json.data["char_id"]
				ConversationManager.char_queue_push(char_id, filepath)
				return true
			else:
				print("Error parsing dialogue file %s" % f)
				return false
	return false


# Move the quest from the unavailable list to the inactive list and add the
# start convo to relevant character convo queue
func _move_quest_to_inactive(id_str:String) -> void:
	inactive_quests[id_str] = unavailable_quests[id_str]
	unavailable_quests.erase(id_str)
	
	# Add start convo to the relevant character convo queue
	var q : Quest = inactive_quests[id_str]
	ConversationManager.char_queue_push(
			q.data["giver"], 
			"%s/%s.json" % [CONVO_FILES_PATH, q.data["start_convo"]])

