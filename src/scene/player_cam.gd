extends Marker3D


const ZOOM_IN_TIME := 0.45
const ZOOM_OUT_TIME := 0.3


var default_trans : Transform3D


func _ready():
	# Save default transform so cam can reset after convos are done
	default_trans = get_transform()
	
	ConversationManager.conversation_started.connect(_frame_interact_object)
	ConversationManager.conversation_ended.connect(_return_to_default_pos)


# Move the camera to view player and NPC being interacted with
func _frame_interact_object():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "rotation", Vector3(0, 1.25, 0), ZOOM_IN_TIME)
	tween.parallel().tween_property($Camera3D, "fov", 37.5, ZOOM_IN_TIME)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.play()


# Tween the camera back to its default transformation
func _return_to_default_pos():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "transform", default_trans, ZOOM_OUT_TIME)
	tween.parallel().tween_property($Camera3D, "fov", 75, ZOOM_OUT_TIME)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.play()
