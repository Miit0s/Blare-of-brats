extends Control
class_name OnboardingTextDisplay

@onready var title: Label = $VBoxContainer/Title
@onready var text: RichTextLabel = $VBoxContainer/Text

@onready var go_back: ColorRect = $GoBack

@onready var page_number: Label = $PageNumber

@export_category("Sound")
@export var on_button_next: WwiseEvent
@export var on_button_back: WwiseEvent

var _texts: Array[String]

var _current_page: int = 0

signal onboarding_text_display_finish

func add_text_page(new_text: String):
	_texts.append(new_text)
	update_page()
	
	if _texts.size() == 1: display_current_page()

func add_texts_page(new_texts: Array[String]):
	for new_text in new_texts:
		add_text_page(new_text)

func display_current_page():
	text.text = _texts[_current_page]
	if _current_page > 0: go_back.show()
	elif _current_page <= 0: go_back.hide()

func update_page():
	page_number.text = str(_current_page + 1) + " / " + str(_texts.size())

func next_page():
	on_button_next.post(self)
	
	if _current_page >= _texts.size() - 1: 
		onboarding_text_display_finish.emit()
		return
	
	_current_page += 1
	
	display_current_page()
	update_page()

func previous_page():
	if _current_page <= 0: return
	
	_current_page -= 1
	
	display_current_page()
	update_page()
	
	on_button_back.post(self)

func reset():
	_current_page = 0
	_texts.clear()
	go_back.hide()

func _input(event: InputEvent) -> void:
	if not visible: return
	
	if event.is_action_pressed("JoinGame"):
		next_page()
		get_viewport().set_input_as_handled()
	
	if event.is_action_pressed("Return"):
		previous_page()
		get_viewport().set_input_as_handled()
