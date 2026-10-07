extends Node
## InventoryManager handles player inventory, money, and keys.
##
## InventoryManager is a singleton class that keeps track of what items a player
## has in their inventory, how much money the player has, and what keys the
## player has collected.


## Amount of money the player has
var currency : int = 999
## Dictionary of items the player has collected and their quantity
var _inventory : Dictionary[String, int] = {}
## List of keys the player has
var _keyring : Array[String] = []

## Signal emitted when the player's inventory changes
signal change_items


## Changes the amount of money the player has by a given amount.  Returns
## [code]true[/code] if the amount is updated and [code]false[/code] if more 
## than the amount held would have been deducted.
func update_currency(delta:int) -> bool:
	# If reducing currency and delta is more than current amount...
	if delta < 0 and abs(delta) > currency:
		# Cannot reduce currency to less than 0
		return false
	# Otherwise...
	currency += delta
	return true


## Sees if the player has any copies of given item.
func inventory_has_item(item:String) -> bool:
	return _inventory.has(item) and _inventory[item] > 0


## Changes the quantity of a given item in the inventory.  Returns 
## [code]true[/code] if the amount is updated and [code]false[/code] if more
## than the number of [code]item[/code] held would be taken away.
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


## Removes a single copy of an item from player's inventory, if it exists.
## Returns [code]true[/code] if the item was successfully removed or 
## [code]false[/code] if the item was not present in the inventory.
func remove_instance_from_inventory(item:String) -> bool:
	if inventory_has_item(item):
		_inventory[item] -= 1
		change_items.emit()
		return true
	else:
		return false


## Checks if the player has the given key ID.
func has_key(key:String) -> bool:
	return _keyring.find(key) != -1


## Adds a key value to the keyring, if it's not already there.  Returns 
## [code]true[/code] if the key ID is added successfully or [code]false[/code]
## if the key was already present.
func give_key_id(key:String) -> bool:
	if not _keyring.has(key):
		_keyring.push_back(key)
		return true
	else:
		return false


## Removes a key ID from the keyring.  Returns [code]true[/code] if the key was
## successfully removed or [code]false[/code] if the key ID was not present in
## the keyring.
func remove_key_id(key:String) -> bool:
	if _keyring.has(key):
		_keyring.remove_at(_keyring.find(key))
		return true
	else:
		return false


## Returns the full keyring, useful for saving game data.
func get_keyring() -> Array[String]:
	return _keyring


## Replaces full keyring, useful for loading game data.
func set_keyring(new_keys:Array) -> void:
	# Massage passed Array into an Array[String]
	_keyring = []
	if new_keys.size() == 0:
		return
	for key in new_keys:
		_keyring.append(String(key))


## Returns the full inventory dictionary.
func get_inventory() -> Dictionary:
	return _inventory


## Replaces the full inventory dictionary.
func set_inventory(new_inv:Dictionary) -> void:
	_inventory = new_inv
