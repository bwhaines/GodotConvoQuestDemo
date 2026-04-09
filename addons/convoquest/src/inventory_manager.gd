extends Node


var currency : int = 999
var _inventory := {}
var _keyring : Array[String] = []

signal change_items


# Change the amount of money the player has by a given amount
func update_currency(delta:int) -> bool:
	# If reducing currency and delta is more than current amount...
	if delta < 0 and abs(delta) > currency:
		# Cannot reduce currency to less than 0
		return false
	# Otherwise...
	currency += delta
	return true


# See if the player has any copies of given item
func inventory_has_item(item:String) -> bool:
	return _inventory.has(item) and _inventory[item] > 0


# Change the quantity of a given item in the inventory
func change_amount_in_inventory(item:String, delta:int) -> bool:
	if not _inventory.has(item):
		_inventory[item] = 0
	
	# Can't remove more than the player has
	if delta < 0 and -delta > _inventory[item]:
		return false
	else:
		_inventory[item] += delta
		change_items.emit()
		return true


# Remove a single copy of an item from player's inventory, if it exists
func remove_instance_from_inventory(item:String) -> bool:
	if inventory_has_item(item):
		_inventory[item] -= 1
		change_items.emit()
		return true
	else:
		return false


# Check if the player has the given key ID
func has_key(key:String) -> bool:
	return _keyring.find(key) != -1


# Add a key value to the keyring, if it's not already there
func give_key_id(key:String) -> bool:
	if not _keyring.has(key):
		_keyring.push_back(key)
		return true
	else:
		return false


# Remove a key string from the keyring, if it is there
func remove_key_id(key:String) -> bool:
	if _keyring.has(key):
		_keyring.remove_at(_keyring.find(key))
		return true
	else:
		return false


# Return the full keyring, useful for saving game data
func get_keyring() -> Array[String]:
	return _keyring


# Replace full keyring, useful for loading game data
func set_keyring(new_keys:Array) -> void:
	# Massage passed Array into an Array[String]
	_keyring = []
	if new_keys.size() == 0:
		return
	for key in new_keys:
		_keyring.append(String(key))


# Return full inventory
func get_inventory() -> Dictionary:
	return _inventory


# Replace the full inventory
func set_inventory(new_inv:Dictionary) -> void:
	_inventory = new_inv
