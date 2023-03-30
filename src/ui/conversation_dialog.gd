class_name ConversationDialog
extends Control


func _ready():
	# Connect end conversation signal to clear self
	ConversationManager.conversation_ended.connect(self.queue_free)
	
	# Load and display the first line of the conversation
	var line := ConversationManager.advance_line()
	if not line.is_empty():
		_display_line(line["text"], line["name"], line["pic"])


# Handle accept inputs to advance dialogues
func _input(event):
	if event.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
		
		# advance_line returns false if the conversation is over
		var new_line := ConversationManager.advance_line()
		if new_line.is_empty():
			visible = false
			queue_free()
		else:
			_display_line(new_line["text"], new_line["name"], new_line["pic"])


# Display a given line, name, and image
func _display_line(text:String, char_name:String, imgpath:String):
	$DialoguePanel/Label.text = text
	$NamePanel/Label.text = char_name
	$DialoguePanel/TextureRect.set_texture(load(imgpath))
