extends CharacterBody3D


signal interacted()

enum PlayerState {
	MOVING,
	TALKING
}

const CONVO_DIALOG = preload("res://src/ui/conversation_dialog.tscn")
const SPEED = 5.0
const ROT_SPEED = 0.02


var state = PlayerState.MOVING


func _ready():
	# Have ConversationManager signals control Player movement state
	ConversationManager.conversation_started.connect(
			func(): state = PlayerState.TALKING)
	ConversationManager.conversation_ended.connect(
			func(): state = PlayerState.MOVING)


func _physics_process(_delta):
	if state == PlayerState.MOVING:
		# Get the input direction and handle the movement/deceleration.
		var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity = Vector3.ZERO
		
		move_and_slide()
		
		# Rotate character
		var input_rot_dir = Input.get_axis("rot_cw", "rot_ccw")
		rotation.y += input_rot_dir * ROT_SPEED


func _input(event):
	# Handle player interacting with NPCs
	if event.is_action_pressed("interact"):
		interacted.emit()
		get_viewport().set_input_as_handled()


# Triggers when an NPC enters the interact area in front of the player
func _on_interact_area_body_entered(body):
	if body is NPC:
		interacted.connect(body.interact_with_player)


func _on_interact_area_body_exited(body):
	if body is NPC:
		interacted.disconnect(body.interact_with_player)
