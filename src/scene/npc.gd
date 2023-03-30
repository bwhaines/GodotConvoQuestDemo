class_name NPC
extends StaticBody3D


const CONVO_DIALOG_CLASS = preload("res://src/ui/conversation_dialog.tscn")


@export_color_no_alpha var mesh_albedo : Color = Color.WHITE
@export var npc_id : String = ""

var convo_ui : ConversationDialog


func _ready():
	$MeshInstance3D.get_active_material(0).albedo_color = mesh_albedo


# Display a relevant conversation, triggered by signal from Player class
func interact_with_player():
	# If there's anything in the queue, display that first
	if ConversationManager.char_queue_pop(npc_id):
		# Pass through; char_queue_pop handles loading the relevant conversation
		pass
	else:
		# Display a response based on relations
		var convo_file := "res://dialogues/%s_neutral.json" % npc_id
		var rel := RelationshipManager.get_relationship_value(npc_id)
		if rel > 2:
			convo_file = "res://dialogues/%s_positive.json" % npc_id
		elif rel < -2:
			convo_file = "res://dialogues/%s_negative.json" % npc_id
		
		ConversationManager.load_conversation(convo_file)
	
	# Only display convo UI after a conversation is loaded
	convo_ui = CONVO_DIALOG_CLASS.instantiate()
	add_child(convo_ui)
