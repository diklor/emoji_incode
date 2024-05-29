@tool
extends PopupPanel

@onready var vbox: VBoxContainer = $margin/vbox


signal on_emoji_chosen(emoji_symbol: String)



var plugin_script: EditorPlugin = null

var opened := false


func _clear_cont(cont: Control) -> void:
	for v: Control in cont.get_children():
		if !v.name.begins_with('_'):
			v.queue_free()
		else:
			v.hide()


func _ready() -> void:
	popup_hide.connect(func() -> void:
		_clear_cont(vbox)
		opened = false
	)


func load_emojis() -> void:
	_clear_cont(vbox)
	size = Vector2.ZERO
	for section_name: String in plugin_script.EMOJIS: #Dictionary[String, Dictionary[String, String]]
		var new_section := vbox.get_node('_section_tmp').duplicate() as VBoxContainer
		new_section.name = section_name
		new_section.get_node('section_name').text = section_name.capitalize()
		new_section.get_node('hbox/_emoji_tmp').hide()
		vbox.add_child(new_section)
		
		for emoji_name: String in plugin_script.EMOJIS[section_name]:
			var emoji_symbol: String = plugin_script.EMOJIS[section_name][emoji_name]
			
			var new_emoji := new_section.get_node('hbox/_emoji_tmp').duplicate() as Button
			new_emoji.name = emoji_name
			new_emoji.text = emoji_symbol
			new_emoji.tooltip_text = emoji_name.capitalize()
			new_emoji.show()
			new_emoji.pressed.connect(func() -> void:
				on_emoji_chosen.emit(emoji_symbol)
				hide()
			)
			new_section.get_node('hbox').add_child(new_emoji)
		
		new_section.show()
		await Engine.get_main_loop().process_frame


func toggle_popup(mouse_pos: Vector2) -> void:
	opened = not opened
	visible = opened
	
	if opened: 
		position = mouse_pos
		await load_emojis()
	
