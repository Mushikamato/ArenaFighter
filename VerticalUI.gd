# VerticalUI.gd - Modern mobile-first UI system
extends Reference

# Main UI container reference
var main_node_ref
var ui_container

# UI sections
var header_section
var character_section  
var action_section
var footer_section

# Current screen state
var current_screen = "MENU"  # MENU, COMBAT, CHARACTER

# Modern color scheme
var colors = {
	"primary": Color(0.2, 0.6, 0.9, 1.0),      # Modern blue
	"secondary": Color(0.3, 0.3, 0.3, 1.0),    # Dark gray
	"success": Color(0.2, 0.8, 0.3, 1.0),      # Green
	"danger": Color(0.9, 0.3, 0.2, 1.0),       # Red
	"background": Color(0.1, 0.1, 0.1, 1.0),   # Almost black
	"surface": Color(0.15, 0.15, 0.15, 1.0),   # Card background
	"text": Color(0.95, 0.95, 0.95, 1.0)       # Light text
}

func initialize(main_node):
	main_node_ref = main_node
	create_main_ui_container()
	create_modern_interface()
	show_main_menu()
	print("Modern Vertical UI initialized!")

func create_main_ui_container():
	# Create full-screen UI container
	ui_container = Control.new()
	ui_container.name = "MainUI"
	ui_container.set_anchors_and_margins_preset(Control.PRESET_WIDE)
	ui_container.color = colors.background
	main_node_ref.add_child(ui_container)

func create_modern_interface():
	# Header section (status bar)
	create_header_section()
	
	# Character section (stats display)
	create_character_section()
	
	# Action section (main content/buttons)
	create_action_section()
	
	# Footer section (navigation)
	create_footer_section()

func create_header_section():
	header_section = create_modern_panel(Vector2(0, 0), Vector2(1080, 200))
	header_section.name = "HeaderSection"
	ui_container.add_child(header_section)
	
	# Title
	var title = create_modern_label("ARENA FIGHTER", 36)
	title.rect_position = Vector2(50, 50)
	title.rect_size = Vector2(400, 50)
	header_section.add_child(title)
	
	# Player info (right side)
	var player_info = create_modern_label("Level 0 | 0 XP | 0 Silver", 20)
	player_info.name = "PlayerInfo"
	player_info.rect_position = Vector2(600, 70)
	player_info.rect_size = Vector2(450, 30)
	player_info.align = Label.ALIGN_RIGHT
	header_section.add_child(player_info)

func create_character_section():
	character_section = create_modern_panel(Vector2(0, 220), Vector2(1080, 300))
	character_section.name = "CharacterSection"
	ui_container.add_child(character_section)
	
	# Health bar
	create_stat_bar("Health", Vector2(50, 50), colors.danger)
	
	# Mana bar  
	create_stat_bar("Mana", Vector2(50, 120), colors.primary)
	
	# Attributes display
	create_attributes_display()

func create_stat_bar(stat_name, position, bar_color):
	# Label
	var label = create_modern_label(stat_name + ":", 18)
	label.rect_position = position
	label.rect_size = Vector2(100, 30)
	character_section.add_child(label)
	
	# Background bar
	var bg_bar = ColorRect.new()
	bg_bar.name = stat_name + "BarBG"
	bg_bar.rect_position = Vector2(position.x + 120, position.y + 5)
	bg_bar.rect_size = Vector2(300, 20)
	bg_bar.color = colors.secondary
	character_section.add_child(bg_bar)
	
	# Progress bar
	var progress_bar = ColorRect.new()
	progress_bar.name = stat_name + "Bar"
	progress_bar.rect_position = Vector2(position.x + 120, position.y + 5)
	progress_bar.rect_size = Vector2(300, 20)
	progress_bar.color = bar_color
	character_section.add_child(progress_bar)
	
	# Value text
	var value_text = create_modern_label("20/20", 16)
	value_text.name = stat_name + "Text"
	value_text.rect_position = Vector2(position.x + 450, position.y)
	value_text.rect_size = Vector2(100, 30)
	character_section.add_child(value_text)

func create_attributes_display():
	var attrs_container = Control.new()
	attrs_container.name = "AttributesContainer"
	attrs_container.rect_position = Vector2(600, 50)
	attrs_container.rect_size = Vector2(450, 200)
	character_section.add_child(attrs_container)
	
	var attributes = ["STR", "AGI", "INT", "END", "ARC"]
	for i in range(attributes.size()):
		var attr = attributes[i]
		var y_pos = i * 35
		
		# Attribute label
		var attr_label = create_modern_label(attr + ":", 16)
		attr_label.rect_position = Vector2(0, y_pos)
		attr_label.rect_size = Vector2(60, 30)
		attrs_container.add_child(attr_label)
		
		# Attribute value
		var attr_value = create_modern_label("3", 16)
		attr_value.name = attr + "Value"
		attr_value.rect_position = Vector2(70, y_pos)
		attr_value.rect_size = Vector2(40, 30)
		attrs_container.add_child(attr_value)
		
		# Plus button (modern style)
		var plus_btn = create_modern_button("+", Vector2(120, y_pos), Vector2(40, 30))
		plus_btn.name = attr + "PlusBtn"
		plus_btn.visible = false  # Hidden until player has points
		attrs_container.add_child(plus_btn)

func create_action_section():
	action_section = create_modern_panel(Vector2(0, 540), Vector2(1080, 800))
	action_section.name = "ActionSection"
	ui_container.add_child(action_section)

func create_footer_section():
	footer_section = create_modern_panel(Vector2(0, 1360), Vector2(1080, 200))
	footer_section.name = "FooterSection"
	ui_container.add_child(footer_section)

# Modern UI component creators
func create_modern_panel(position, size):
	var panel = ColorRect.new()
	panel.rect_position = position
	panel.rect_size = size
	panel.color = colors.surface
	
	# Add subtle border
	var border = Control.new()
	border.rect_size = size
	border.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(border)
	
	return panel

func create_modern_label(text, font_size):
	var label = Label.new()
	label.text = text
	label.add_color_override("font_color", colors.text)
	
	# Create dynamic font
	var font = DynamicFont.new()
	font.font_data = load("res://fonts/arial.ttf") if ResourceLoader.exists("res://fonts/arial.ttf") else null
	font.size = font_size
	if font.font_data:
		label.add_font_override("font", font)
	
	return label

func create_modern_button(text, position, size):
	var button = Button.new()
	button.text = text
	button.rect_position = position
	button.rect_size = size
	
	# Modern button styling
	var stylebox = StyleBoxFlat.new()
	stylebox.bg_color = colors.primary
	stylebox.corner_radius_top_left = 8
	stylebox.corner_radius_top_right = 8
	stylebox.corner_radius_bottom_left = 8
	stylebox.corner_radius_bottom_right = 8
	
	button.add_stylebox_override("normal", stylebox)
	button.add_color_override("font_color", colors.text)
	
	return button

# Screen management
func show_main_menu():
	current_screen = "MENU"
	clear_action_section()
	
	# Create main menu buttons
	var fight_btn = create_modern_button("FIND OPPONENT", Vector2(200, 100), Vector2(680, 80))
	fight_btn.connect("pressed", main_node_ref, "_on_find_opponent_pressed")
	action_section.add_child(fight_btn)
	
	var character_btn = create_modern_button("CHARACTER", Vector2(200, 220), Vector2(680, 80))
	character_btn.connect("pressed", self, "show_character_screen")
	action_section.add_child(character_btn)
	
	var save_btn = create_modern_button("SAVE GAME", Vector2(200, 340), Vector2(680, 80))
	save_btn.connect("pressed", main_node_ref, "save_game")
	action_section.add_child(save_btn)

func show_character_screen():
	current_screen = "CHARACTER"
	clear_action_section()
	
	# Character info and attribute spending
	var info_label = create_modern_label("Spend your attribute points:", 24)
	info_label.rect_position = Vector2(50, 50)
	info_label.rect_size = Vector2(800, 40)
	action_section.add_child(info_label)
	
	# Back button
	var back_btn = create_modern_button("BACK", Vector2(200, 600), Vector2(680, 80))
	back_btn.connect("pressed", self, "show_main_menu")
	action_section.add_child(back_btn)

func show_combat_interface(player_stats, enemy_data):
	current_screen = "COMBAT"
	clear_action_section()
	
	# Enemy info
	var enemy_label = create_modern_label("VS: " + enemy_data.name + " (" + enemy_data.style.capitalize() + ")", 28)
	enemy_label.rect_position = Vector2(50, 50)
	enemy_label.rect_size = Vector2(800, 40)
	action_section.add_child(enemy_label)
	
	# Combat buttons
	var attack_btn = create_modern_button("ATTACK", Vector2(100, 150), Vector2(400, 100))
	attack_btn.connect("pressed", main_node_ref, "_on_attack_pressed")
	action_section.add_child(attack_btn)
	
	var defend_btn = create_modern_button("DEFEND", Vector2(580, 150), Vector2(400, 100))
	defend_btn.connect("pressed", main_node_ref, "_on_defend_pressed")
	action_section.add_child(defend_btn)
	
	var flee_btn = create_modern_button("FLEE", Vector2(300, 300), Vector2(400, 80))
	flee_btn.connect("pressed", main_node_ref, "_on_flee_pressed")
	action_section.add_child(flee_btn)

func clear_action_section():
	for child in action_section.get_children():
		child.queue_free()

# Update functions
func update_character_display(character_stats):
	# Update health bar
	update_stat_bar("Health", character_stats.current_health, character_stats.max_health)
	
	# Update mana bar  
	update_stat_bar("Mana", character_stats.current_mana, character_stats.max_mana)
	
	# Update attributes
	var attrs = character_stats.get_attributes()
	for attr in attrs:
		var attr_node = character_section.get_node_or_null("AttributesContainer/" + attr.to_upper() + "Value")
		if attr_node:
			attr_node.text = str(attrs[attr])

func update_stat_bar(stat_name, current_value, max_value):
	var bar = character_section.get_node_or_null(stat_name + "Bar")
	var text = character_section.get_node_or_null(stat_name + "Text")
	
	if bar and text:
		var percentage = float(current_value) / float(max_value)
		bar.rect_size.x = 300 * percentage
		text.text = str(current_value) + "/" + str(max_value)

func update_progress_display(level, experience, money, unspent_points):
	var player_info = header_section.get_node_or_null("PlayerInfo")
	if player_info:
		player_info.text = "Level " + str(level) + " | " + str(experience) + " XP | " + str(money) + " Silver"
	
	# Show/hide plus buttons based on unspent points
	show_plus_buttons(unspent_points > 0)
