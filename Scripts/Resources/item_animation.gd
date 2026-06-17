extends Resource
class_name ItemAnimation

@export var skin: ControllerSlot.PossibleSkin
@export var idle_animation: SpriteFrames
@export var attack_animations: SpriteFrames

@export var attack_offset_left: Vector2 = Vector2.ZERO
@export var attack_offset_right: Vector2 = Vector2.ZERO
@export var attack_offset_front: Vector2 = Vector2.ZERO
@export var attack_offset_back: Vector2 = Vector2.ZERO
