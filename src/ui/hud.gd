extends Control


const QUEST_LABEL_HEADER : String = "Quests:\n"


@onready var quest_label = $URContainer/QuestsLabel


func _ready():
	QuestManager.quest_started.connect(update_quests_label)
	QuestManager.quest_completed.connect(update_quests_label)
	QuestManager.quest_failed.connect(update_quests_label)
	update_quests_label()


# Update the list of quests in the UI
func update_quests_label() -> void:
	quest_label.text = QUEST_LABEL_HEADER
	for quest in QuestManager.active_quests.values():
		quest_label.text += "* %s\n" % quest.data["name"]
	for quest in QuestManager.completed_quests.values():
		quest_label.text += "[DONE] %s\n" % quest.data["name"]
	for quest in QuestManager.failed_quests.values():
		quest_label.text += "[FAIL] %s\n" % quest.data["name"]
