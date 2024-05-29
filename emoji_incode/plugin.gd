@tool
extends EditorPlugin

const EMOJI_POPUP_SCENE := preload('res://addons/emoji_incode/emoji_popup.tscn')

var added_emojis: Array[Control] = []
var keycode: InputEventKey = null
var emoji_popup: Node = null


const EMOJIS: Dictionary = { #Dictionary[String, Dictionary[String, String]]
	'default': {
		'wow': '🙀', #[240, 159, 153, 128]
		'like': '👍', #[240, 159, 152, 136]
		'dislike': '👎', #[240, 159, 152, 136]
		'this': '👆',
		'soon': '🛠',
		'love it': '😍',
		'cool': '😎', #[240, 159, 152, 142]
		'erm': '😐',
		'laugh': '😂',
		'angry': '😡',
		'damn': '🔥',
		'hehehe': '😈', #[240, 159, 152, 136]
	},
	'marks': {
		'yes': '✅',
		'no': '❌',
		'redflag': '🚩',
		'heart': '♥',
		'stop': '🚫',
	},
	'other': {
		'finally': '🎉',
		'star': '⭐',
		'money': '🤑',
		'locked': '🔒',
		'trophy': '🏆',
		'juicy': '🍹',
	}
}

func decode_custom_emoji(array: PackedByteArray):
	return array.get_string_from_utf8()

func encode_custom_emoji(emoji_symbol: String) -> PackedByteArray:
	var emoji_buffer :=  emoji_symbol.to_utf8_buffer()
	if emoji_symbol == emoji_buffer.get_string_from_utf8():
		return emoji_buffer
	return PackedByteArray()


func _clear_emojis() -> void:
	if !added_emojis.is_empty():
		for v: Control in added_emojis:
			var parent := v.get_parent()
			if parent:	parent.remove_child(v)
			v.queue_free()
	added_emojis.clear()


func _get_script_editor() -> ScriptEditor:
	return get_editor_interface().get_script_editor()
	
func _get_base_editor() -> CodeEdit:
	return _get_script_editor().get_current_editor().get_base_editor()


func _enter_tree() -> void:
	var script_editor := _get_script_editor()
	var current_editor = script_editor.get_current_editor()
	var base_editor := current_editor.get_base_editor()
	
	keycode = InputEventKey.new()
	keycode.keycode = KEY_PERIOD
	keycode.alt_pressed = true
	set_process_input(true)
	
#	script_editor.editor_script_changed.connect(func(script: Script) -> void:
#		prints(script)
#	)



func _input(event: InputEvent) -> void:
	if event.is_match(keycode) and event.is_pressed() and not event.is_echo():
		if not emoji_popup:
			emoji_popup = EMOJI_POPUP_SCENE.instantiate()
			emoji_popup.plugin_script = self
			_get_base_editor().add_child(emoji_popup)
			emoji_popup.set_owner(_get_base_editor())
			emoji_popup.on_emoji_chosen.connect(func(emoji_symbol: String) -> void:
				var base_editor := _get_base_editor()
				if base_editor: #Damn 🔥🔥🔥🔥
					for i in randi_range(3, 6):
						base_editor.insert_text_at_caret(emoji_symbol)
			)
		else:
			var base_editor := _get_base_editor()
			if emoji_popup.get_parent() and emoji_popup.get_parent() != base_editor:
				emoji_popup.reparent(base_editor)
		emoji_popup.toggle_popup(get_viewport().get_mouse_position())



func _exit_tree() -> void:
	keycode = null
	if emoji_popup != null:
		if emoji_popup.get_parent():
			emoji_popup.get_parent().remove_child(emoji_popup)
		emoji_popup.queue_free()
	_clear_emojis()
