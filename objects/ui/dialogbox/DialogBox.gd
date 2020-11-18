extends MarginContainer


signal disable_input
signal enable_input

func _ready():
	visible = false
	set_process_input(false)

func _input(event):
	if event.is_action_pressed("ui_accept"):
		visible = false
		emit_signal("enable_input")

func show_dialog(text):
	if not visible:
		emit_signal("disable_input")
		set_process_input(true)
		set_dialog(text)
		visible = true

func set_dialog(text):
	$Panel/Label.text = text

func get_percent_visible():
	return $Panel/Label.percent_visible

func set_percent_visible(p : float):
	$Panel/Label.percent_visible = clamp(p, 0.0, 1.0)


func _on_Page_trigger():
	pass # Replace with function body.
