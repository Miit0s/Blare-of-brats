extends Control

@onready var controller_slot_container: HBoxContainer = $ControllerSlotContainer

@export var max_player: int = 4
@export var controller_slot: PackedScene

func _input(event: InputEvent) -> void:
	pass

func add_controller_slot():
	if controller_slot_container.get_children().size() >= 4: return
	
	var controller_slot_instance: ControllerSlot = controller_slot.instantiate()
	controller_slot_container.add_child(controller_slot_instance)
