extends Control
class_name OnboardingTextDisplay

@onready var title: Label = $TitleBackground/Title
@onready var text: RichTextLabel = $Text
@onready var image_with_text: TextureRect = $ImageWithText

@onready var go_back: TextureRect = $GoBack

@onready var page_number: RichTextLabel = $PageNumberBackground/PageNumber

var _datas: Array[OnboardingHelpBoxContent]

var _current_page: int = 0

signal onboarding_text_display_finish

func add_text_page(new_text: OnboardingHelpBoxContent):
	_datas.append(new_text)
	update_page()
	
	if _datas.size() == 1: display_current_page()

func add_texts_page(new_texts: Array[OnboardingHelpBoxContent]):
	for new_text in new_texts:
		add_text_page(new_text)

func display_current_page():
	title.text = _datas[_current_page].title
	text.text = _datas[_current_page].text
	
	if _datas[_current_page].image_linked:
		image_with_text.texture = _datas[_current_page].image_linked
	else:
		image_with_text.texture = null
	
	if _current_page > 0: go_back.show()
	elif _current_page <= 0: go_back.hide()

func update_page():
	page_number.text = str(_current_page + 1) + " / " + str(_datas.size())

func next_page():
	if _current_page >= _datas.size() - 1: 
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

func reset():
	_current_page = 0
	_datas.clear()
	go_back.hide()

func _input(event: InputEvent) -> void:
	if not visible: return
	
	if event.is_action_pressed("JoinGame"):
		next_page()
		get_viewport().set_input_as_handled()
	
	if event.is_action_pressed("Return"):
		previous_page()
		get_viewport().set_input_as_handled()
