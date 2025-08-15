# ArenaGameManager.gd - Simple main controller for Arena Fighter
extends Node

# Core systems
var character_stats
var current_enemy
var game_state = "MENU"  # MENU, COMBAT, VICTORY, DEFEAT

# Game data
var player_level = 0
var player_experience = 0
var player_money = 0
var unspent_attribute_points = 0
var arena_rank = "Novice"
var wins = 0
var losses = 0

# UI reference
var ui_manager

func _ready():
	print("=== Arena Fighter Starting ===")
	initialize_game_systems()
	setup_mobile_settings()

func initialize_game_systems():
	# Load character stats system
	var CharacterStatsScript = load("res://CharacterStats.gd")
	character_stats = CharacterStatsScript.new()
	character_stats.connect("stats_changed", self, "_on_character_stats_changed")
	
	# Load UI manager (we'll create this next)
	var UIManagerScript = load("res://VerticalUI.gd")
	ui_manager = UIManagerScript.new()
	ui_manager.initialize(self)
	
	print("Game systems initialized!")

func setup_mobile_settings():
	# Ensure we're in portrait mode
	OS.set_screen_orientation(OS.SCREEN_PORTRAIT)
	print("Mobile settings applied")

func _on_character_stats_changed():
	# Update UI when character stats change
	update_ui()

func update_ui():
	if ui_manager:
		ui_manager.update_character_display(character_stats)
		ui_manager.update_progress_display(player_level, player_experience, player_money, unspent_attribute_points)

# Combat system
func start_combat_with_enemy(enemy_data):
	current_enemy = enemy_data
	game_state = "COMBAT"
	ui_manager.show_combat_interface(character_stats, current_enemy)

func handle_combat_result(player_won):
	if player_won:
		wins += 1
		var xp_reward = current_enemy.level * 25 + 50
		var money_reward = current_enemy.level * 10 + 25
		gain_experience(xp_reward)
		player_money += money_reward
		print("Victory! Gained ", xp_reward, " XP and ", money_reward, " silver")
	else:
		losses += 1
		print("Defeat! Better luck next time.")
	
	game_state = "MENU"
	update_ui()

# Progression system
func gain_experience(amount):
	player_experience += amount
	check_for_level_up()

func check_for_level_up():
	var xp_needed = get_xp_needed_for_next_level()
	if player_experience >= xp_needed:
		level_up()

func get_xp_needed_for_next_level():
	return (player_level + 1) * 200

func level_up():
	player_level += 1
	player_experience = 0  # Reset XP for next level
	unspent_attribute_points += 3
	player_money += 50
	
	# Restore health and mana
	character_stats.restore_health_and_mana()
	
	print("LEVEL UP! Now level ", player_level)
	update_ui()

# Attribute spending
func spend_attribute_point(attribute_name):
	if unspent_attribute_points > 0:
		character_stats.increase_attribute(attribute_name)
		unspent_attribute_points -= 1
		update_ui()
		return true
	return false

# Save/Load system (essential for mobile)
func save_game():
	var save_data = {
		"level": player_level,
		"experience": player_experience, 
		"money": player_money,
		"unspent_points": unspent_attribute_points,
		"wins": wins,
		"losses": losses,
		"attributes": character_stats.get_attributes()
	}
	
	var save_file = File.new()
	save_file.open("user://arena_fighter_save.dat", File.WRITE)
	save_file.store_string(JSON.print(save_data))
	save_file.close()
	print("Game saved!")

func load_game():
	var save_file = File.new()
	if save_file.file_exists("user://arena_fighter_save.dat"):
		save_file.open("user://arena_fighter_save.dat", File.READ)
		var save_data = JSON.parse(save_file.get_as_text()).result
		save_file.close()
		
		player_level = save_data.get("level", 0)
		player_experience = save_data.get("experience", 0)
		player_money = save_data.get("money", 0)
		unspent_attribute_points = save_data.get("unspent_points", 0)
		wins = save_data.get("wins", 0)
		losses = save_data.get("losses", 0)
		
		if save_data.has("attributes"):
			character_stats.set_attributes(save_data.attributes)
		
		print("Game loaded!")
		return true
	return false