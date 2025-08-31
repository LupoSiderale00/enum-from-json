@tool
extends EditorPlugin

# Various inspector UI elements
var dock: VBoxContainer
var JSON_file_path_analyser: LineEdit
var JSON_file_path: LineEdit
var Output_file_path: LineEdit
var output_name: LineEdit
var file_dialog: FileDialog
var folder_dialog: FileDialog
var active_target: LineEdit
var enum_key_selector: OptionButton

# Toolbar button 
var regen_button: Button
var regen_button_dock : Button

# Options
var showing_button_checkbutton : CheckButton 
func _enter_tree():
	# Create inspector UI 
	dock = VBoxContainer.new()
	dock.name = "Enum from JSON"
	
	# Title JSON Analyser
	var section_label = Label.new()
	section_label.text = "JSON file input"
	section_label.add_theme_color_override("font_color", Color(1,1,1))
	section_label.add_theme_font_size_override("font_size", 18)
	dock.add_child(section_label)
	
	# JSON file picker
	var hbox_a = HBoxContainer.new()
	var label_a = Label.new()
	label_a.text = "JSON file path:"
	hbox_a.add_child(label_a)
	JSON_file_path = LineEdit.new()
	JSON_file_path.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox_a.add_child(JSON_file_path)
	var browse_a = Button.new()
	browse_a.text = "Browse"
	browse_a.pressed.connect(func(): _open_file_picker(JSON_file_path))
	hbox_a.add_child(browse_a)
	dock.add_child(hbox_a)
	
	#Analyser button
	var label_analyser = Label.new()
	label_analyser.text = "From JSON Select key for enum"
	dock.add_child(label_analyser)
	enum_key_selector = OptionButton.new()
	enum_key_selector.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	dock.add_child(enum_key_selector)
	
	# Separator 
	var separator = HSeparator.new()
	dock.add_child(separator)
	
	# Output section 
	var section_label_2 = Label.new()
	section_label_2.text = "Output options"
	section_label_2.add_theme_color_override("font_color", Color(1,1,1))
	section_label_2.add_theme_font_size_override("font_size", 18)
	dock.add_child(section_label_2)

	# Output folder picker
	var hbox_b = HBoxContainer.new()
	var label_b = Label.new()
	label_b.text = "Output folder:"
	hbox_b.add_child(label_b)
	Output_file_path = LineEdit.new()
	Output_file_path.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox_b.add_child(Output_file_path)
	var browse_b = Button.new()
	browse_b.text = "Browse"
	browse_b.pressed.connect(func(): _open_folder_picker(Output_file_path))
	hbox_b.add_child(browse_b)
	dock.add_child(hbox_b)

	# Output filename
	var hbox_c = HBoxContainer.new()
	var label_c = Label.new()
	label_c.text = "Output filename:"
	hbox_c.add_child(label_c)
	output_name = LineEdit.new()
	output_name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox_c.add_child(output_name)
	dock.add_child(hbox_c)

	# File dialog picker for JSON
	file_dialog = FileDialog.new()
	file_dialog.access = FileDialog.ACCESS_RESOURCES
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dialog.filters = ["*.json"]
	file_dialog.connect("file_selected", Callable(self, "_on_file_selected"))
	dock.add_child(file_dialog)

	# Output folder dialog picker
	folder_dialog = FileDialog.new()
	folder_dialog.access = FileDialog.ACCESS_RESOURCES
	folder_dialog.file_mode = FileDialog.FILE_MODE_OPEN_DIR
	folder_dialog.connect("dir_selected", Callable(self, "_on_dir_selected"))
	dock.add_child(folder_dialog)
	
	# Gen button
	regen_button_dock = Button.new()
	regen_button_dock.text = "Generate Enum"
	regen_button_dock.tooltip_text = "Generate Enum from selected JSON. Before it can work, make sure to open the Enum from JSON tab and set the file paths and name"
	regen_button_dock.pressed.connect(_generate_enum)
	dock.add_child(regen_button_dock)

	# Separator 
	var separator_2 = HSeparator.new()
	dock.add_child(separator_2)
	
	# Options label
	var section_label_3 = Label.new()
	section_label_3.text = "Plug-in Options"
	section_label_3.add_theme_color_override("font_color", Color(1,1,1))
	section_label_3.add_theme_font_size_override("font_size", 18)
	dock.add_child(section_label_3)
	
	# Checkbox 
	showing_button_checkbutton = CheckButton.new()
	showing_button_checkbutton.text = "Show Generate Enum button on top bar"
	showing_button_checkbutton.button_pressed = true
	showing_button_checkbutton.pressed.connect(_change_top_button)
	dock.add_child(showing_button_checkbutton)
	
	#debug reload button
	var refresh_button = Button.new()
	refresh_button.text = "Refresh Plugin"
	refresh_button.pressed.connect(Callable(self, "_refresh_plugin"), CONNECT_DEFERRED)
	dock.add_child(refresh_button)
	update_enum_keys(JSON_file_path.text)
	
	# Add dock to editor
	add_control_to_dock(DOCK_SLOT_RIGHT_UL, dock)
	
	#Shows dock when refreshing/opening the plug in
	dock.show()
	
	# Toolbar button 
	regen_button = Button.new()
	regen_button.text = "Generate Enum"
	regen_button.tooltip_text = "Generate Enum from selected JSON. Before it can work, make sure to open the Enum from JSON tab and set the file paths and name"
	regen_button.pressed.connect(_generate_enum)
	add_control_to_container(CONTAINER_TOOLBAR, regen_button)
	
func _refresh_plugin():
	_exit_tree()
	call_deferred("_enter_tree")
	print("Plugin reloaded, changes should be visible now rockstar")

func _exit_tree():
	remove_control_from_docks(dock)
	dock.free()
	remove_control_from_container(CONTAINER_TOOLBAR, regen_button)
	regen_button.queue_free()

func update_enum_keys(json_path: String):
	enum_key_selector.clear()
	
	if not FileAccess.file_exists(json_path):
		push_warning("JSON file not found: " + json_path)
		return

	var file = FileAccess.open(json_path, FileAccess.READ)
	var text = file.get_as_text()
	file.close()
	
	var data = JSON.parse_string(text)
	if typeof(data) != TYPE_DICTIONARY:
		push_warning("JSON root must be a dictionary")
		return
	
	# Take the first item to read its keys
	var first_item = null
	for key in data.keys():
		first_item = data[key]
		break
	
	if typeof(first_item) != TYPE_DICTIONARY:
		push_warning("First item is not a dictionary")
		return
	
	# Add all subkeys to dropdown
	for subkey in first_item.keys():
		enum_key_selector.add_item(str(subkey))

# File/folder picker handlers
func _open_file_picker(target: LineEdit):
	active_target = target
	file_dialog.popup_centered_ratio(0.5)

func _open_folder_picker(target: LineEdit):
	active_target = target
	folder_dialog.current_dir = "res://"
	folder_dialog.popup_centered_ratio(0.5)

func _on_file_selected(path: String):
	if active_target:
		active_target.text = path
	update_enum_keys(JSON_file_path.text)

func _on_dir_selected(path: String):
	if active_target:
		active_target.text = path

func _generate_enum():
	if JSON_file_path.text == "" or Output_file_path.text == "" or output_name.text == "":
		push_error("Please fill JSON file, output folder, and output filename.")
		return

	if not FileAccess.file_exists(JSON_file_path.text):
		push_error("JSON file not found: " + JSON_file_path.text)
		return

	# Read JSON
	var file = FileAccess.open(JSON_file_path.text, FileAccess.READ)
	var text = file.get_as_text()
	file.close()
	var data = JSON.parse_string(text)
	if typeof(data) != TYPE_DICTIONARY:
		push_error("JSON root must be a Dictionary.")
		return

	# Get the subkey chosen in the dropdown
	var selected_index = enum_key_selector.get_selected_id()
	if selected_index == -1:
		push_error("Please select a subkey from the dropdown.")
		return
	var chosen_subkey = enum_key_selector.get_item_text(selected_index)

	# Generate enum
	var lines = []
	lines.append("# Auto-generated from JSON. Do not edit manually.")
	lines.append("enum ItemID {")

	for key in data.keys():
		var entry = data[key]
		if typeof(entry) == TYPE_DICTIONARY and entry.has(chosen_subkey):
			var enum_name = str(entry[chosen_subkey]).to_upper().replace(" ", "_")
			lines.append("\t%s," % enum_name)

	lines.append("}")

	# Save
	var final_path = Output_file_path.text + "/" + output_name.text + ".gd"
	var out = FileAccess.open(final_path, FileAccess.WRITE)
	if out == null:
		push_error("Cannot write to: " + final_path)
		return
	out.store_string("\n".join(lines))
	out.close()
	get_editor_interface().get_resource_filesystem().scan()
	print("Enum generated at: %s using subkey '%s'" % [final_path, chosen_subkey])

func _change_top_button():
	if showing_button_checkbutton.button_pressed == true:
		add_control_to_container(CONTAINER_TOOLBAR, regen_button)
	else:
		remove_control_from_container(CONTAINER_TOOLBAR, regen_button)
