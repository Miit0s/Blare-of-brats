extends TextureButton
class_name TextureButtonFocusReplace

@export var texture_focus_remplacement: Texture2D

var _texture_normal_origine: Texture2D
var _texture_hover_origine: Texture2D

func _ready() -> void:
	_texture_normal_origine = texture_normal
	_texture_hover_origine = texture_hover
	
	focus_entered.connect(_on_focus_entered)
	focus_exited.connect(_on_focus_exited)

func _on_focus_entered() -> void:
	texture_normal = texture_focus_remplacement
	texture_hover = texture_focus_remplacement

func _on_focus_exited() -> void:
	texture_normal = _texture_normal_origine
	texture_hover = _texture_hover_origine
