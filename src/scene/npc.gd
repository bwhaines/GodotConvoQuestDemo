class_name NPC
extends StaticBody3D


const CONVO_DIALOG_CLASS = preload("res://src/ui/conversation_dialog.tscn")


@export_color_no_alpha var mesh_albedo : Color = Color.WHITE
@export var npc_id : String = ""

var convo_ui : ConversationDialog


func _ready():
	$MeshInstance3D.get_active_material(0).albedo_color = mesh_albedo


# Handle accept inputs to advance dialogues
func _input(event):
	if event.is_action_pressed("ui_accept"):
		if convo_ui != null:
			get_viewport().set_input_as_handled()
			# advance_line returns false if the conversation is over
			if not ConversationManager.advance_line(convo_ui):
				convo_ui.visible = false
				convo_ui.queue_free()
				convo_ui = null


# Display a relevant conversation, triggered by signal from Player class
func interact_with_player():
	print("Player interacted with %s" % npc_id)
	
	convo_ui = CONVO_DIALOG_CLASS.instantiate()
	add_child(convo_ui)
	
	# If there's anything in the queue, display that first
	if ConversationManager.char_queue_pop(npc_id, convo_ui):
		return
	else:
		# Display a response based on relations
		var convo_file := "res://dialogues/%s_neutral.json" % npc_id
		var rel := RelationshipManager.get_relationship_value(npc_id)
		if rel > 2:
			convo_file = "res://dialogues/%s_positive.json" % npc_id
		elif rel < -2:
			convo_file = "res://dialogues/%s_negative.json" % npc_id
		
		ConversationManager.load_conversation(convo_file, convo_ui)
