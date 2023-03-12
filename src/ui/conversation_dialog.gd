class_name ConversationDialog
extends Control


# Display a given line, name, and image
func display_line(text:String, name:String, imgpath:String):
	$DialoguePanel/Label.text = text
	$NamePanel/Label.text = name
	$DialoguePanel/TextureRect.set_texture(load(imgpath))
