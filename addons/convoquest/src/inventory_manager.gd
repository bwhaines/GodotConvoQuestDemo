extends Node


var _inventory := {}


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
		return true


# Remove a single copy of an item from player's inventory, if it exists
func remove_instance_from_inventory(item:String) -> bool:
	if inventory_has_item(item):
		_inventory[item] -= 1
		return true
	else:
		return false
