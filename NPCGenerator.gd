# NPCGenerator.gd - Handles NPC creation with proper stat distribution
extends Reference

# NPC style templates with stat distribution preferences
var npc_styles = {
	"bandit": {
		"name": "Bandit",
		"description": "Balanced fighter with keen intuition",
		"stat_focus": "intuition",
		"base_names": ["Scarred Jake", "Quick-Draw Bill", "Silent Mary", "Iron Tom", "Backstab Pete"]
	},
	"goblin": {
		"name": "Goblin", 
		"description": "Small and agile fighter",
		"stat_focus": "agility",
		"base_names": ["Snaggletooth", "Spitfire", "Quickstep", "Redeye", "Nimblefeet"]
	},
	"ghoul": {
		"name": "Ghoul",
		"description": "Tough undead with high endurance", 
		"stat_focus": "endurance",
		"base_names": ["Pale Horror", "Rotgut", "Bonechill", "Gravemaw", "Deathwhisper"]
	}
}

# Generate a single NPC for the arena
func generate_npc(player_level):
	# Choose random NPC style
	var style_names = npc_styles.keys()
	var chosen_style = style_names[randi() % style_names.size()]
	var style_data = npc_styles[chosen_style]
	
	# Generate NPC data
	var npc = {
		"id": generate_unique_id(),
		"name": get_random_name(style_data.base_names),
		"style": chosen_style,
		"level": player_level,
		"description": style_data.description
	}
	
	# Generate stats based on level and style
	generate_npc_stats(npc, style_data)
	
	return npc

# Generate stats according to your rules
func generate_npc_stats(npc, style_data):
	var level = npc.level
	var total_points = 12 + (level * 4)  # Level 0 = 12 points, +4 per level
	
	# Base stats (minimum 1 each, no arcane until level 5)
	npc["strength"] = 1
	npc["agility"] = 1
	npc["intuition"] = 1
	npc["endurance"] = 1
	npc["arcane"] = 0 if level < 5 else 1
	
	# Points to distribute
	var remaining_points = total_points - 4  # Used 4 points for base stats
	if level >= 5:
		remaining_points -= 1  # Used 1 point for arcane
	
	# Distribute points based on NPC style
	var focus_stat = style_data.stat_focus
	
	for i in range(remaining_points):
		# 50% chance to put point in focus stat, 50% random distribution
		if randf() < 0.5:
			# Put in focus stat
			npc[focus_stat] += 1
		else:
			# Random distribution
			var stats = ["strength", "agility", "intuition", "endurance"]
			if level >= 5:
				stats.append("arcane")
			var random_stat = stats[randi() % stats.size()]
			npc[random_stat] += 1
	
	# Calculate derived stats using same formulas as player
	calculate_npc_derived_stats(npc)

# Calculate health, damage, etc. using same formulas as player
func calculate_npc_derived_stats(npc):
	# Health: Endurance * 5 + base 5
	npc["max_health"] = npc.endurance * 5 + 5
	npc["current_health"] = npc["max_health"]
	
	# Mana: Arcane * 4 + base 10
	npc["max_mana"] = npc.arcane * 4 + 10
	npc["current_mana"] = npc["max_mana"]
	
	# Physical Damage: Strength * 1 + base 2
	npc["physical_damage"] = npc.strength * 1 + 2
	
	# Critical Chance: Intuition * 0.75% (capped at 50%)
	npc["critical_chance"] = min(npc.intuition * 0.75, 50.0)
	
	# Evasion: Agility * 0.6% (capped at 40%)
	npc["evasion_chance"] = min(npc.agility * 0.6, 40.0)

# Generate multiple NPCs for arena
func generate_arena_opponents(player_level, count = 5):
	var opponents = []
	
	for i in range(count):
		var npc = generate_npc(player_level)
		opponents.append(npc)
	
	print("Generated ", count, " opponents for level ", player_level, " player")
	return opponents

# Utility functions
func get_random_name(name_list):
	return name_list[randi() % name_list.size()]

func generate_unique_id():
	return "npc_" + str(randi() % 10000) + "_" + str(OS.get_ticks_msec())

# Get NPC difficulty rating for UI display
func get_difficulty_rating(npc, player_level):
	var total_stats = npc.strength + npc.agility + npc.intuition + npc.endurance + npc.arcane
	var expected_stats = 12 + (player_level * 4)
	
	var ratio = float(total_stats) / float(expected_stats)
	
	if ratio < 0.8:
		return "Easy"
	elif ratio < 1.2:
		return "Medium" 
	else:
		return "Hard"

# Get display info for UI
func get_npc_display_info(npc, player_level):
	return {
		"name": npc.name,
		"style": npc.style.capitalize(),
		"level": npc.level,
		"health": str(npc.current_health) + "/" + str(npc.max_health),
		"damage": npc.physical_damage,
		"difficulty": get_difficulty_rating(npc, player_level)
	}
