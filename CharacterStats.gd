# CharacterStats.gd - Handles all character attributes and derived stats
extends Reference

# Base Attributes (can be changed/upgraded)
var strength = 3
var agility = 3  
var intuition = 3
var endurance = 3
var arcane = 3

# Derived Stats (calculated from attributes)
var max_health = 0
var current_health = 0
var max_mana = 0
var current_mana = 0
var physical_damage = 0
var critical_chance = 0
var evasion_chance = 0
var carry_weight = 0
var health_regen = 0
var mana_regen = 0

# Signals for when stats change
signal stats_changed
signal health_changed
signal mana_changed

func _init():
	calculate_all_stats()

# FORMULAS - All the stat calculations in one place
func calculate_all_stats():
	var old_max_health = max_health
	var old_max_mana = max_mana
	
	# Health: Endurance * 5 + base 5 (so 3 Endurance = 20 health)
	max_health = endurance * 5 + 5
	if current_health == 0 or current_health > max_health:
		current_health = max_health
	
	# Mana: Arcane * 4 + base 10 (so 3 Arcane = 22 mana)
	max_mana = arcane * 4 + 10
	if current_mana == 0 or current_mana > max_mana:
		current_mana = max_mana
	
	# Physical Damage: Strength * 1 + base 2 (so 3 Strength = 5 damage)
	physical_damage = strength * 1 + 2
	
	# Critical Chance: Intuition * 0.75% (so 20 Intuition = 15% crit)
	critical_chance = min(intuition * 0.75, 50.0)
	
	# Evasion: Agility * 0.6% (so 25 Agility = 15% evasion)
	evasion_chance = min(agility * 0.6, 40.0)
	
	# Carry Weight: Strength * 2.5 + base 10 (so 3 Strength = 17.5 weight)
	carry_weight = strength * 2.5 + 10
	
	# Health Regen: Endurance * 0.05 per second
	health_regen = endurance * 0.05
	
	# Mana Regen: Arcane * 0.075 per second  
	mana_regen = arcane * 0.075
	
	# Emit signals when stats change
	emit_signal("stats_changed")
	if old_max_health != max_health:
		emit_signal("health_changed")
	if old_max_mana != max_mana:
		emit_signal("mana_changed")

# Increase an attribute by 1 point
func increase_attribute(attribute_name):
	match attribute_name:
		"strength":
			strength += 1
		"agility":
			agility += 1
		"intuition":
			intuition += 1
		"endurance":
			endurance += 1
		"arcane":
			arcane += 1
	
	calculate_all_stats()
	return true

# Combat functions
func take_damage(amount):
	current_health = max(0, current_health - amount)
	emit_signal("health_changed")
	return current_health <= 0  # Returns true if dead

func use_mana(amount):
	if current_mana >= amount:
		current_mana -= amount
		emit_signal("mana_changed")
		return true
	return false

func heal(amount):
	current_health = min(max_health, current_health + amount)
	emit_signal("health_changed")

func restore_mana(amount):
	current_mana = min(max_mana, current_mana + amount)
	emit_signal("mana_changed")

# Reset character to starting values
func reset_to_defaults():
	strength = 3
	agility = 3
	intuition = 3
	endurance = 3
	arcane = 3
	current_health = 0  # Will be set by calculate_all_stats
	current_mana = 0    # Will be set by calculate_all_stats
	
	calculate_all_stats()

# Get all attributes as a dictionary (useful for saving/loading)
func get_attributes():
	return {
		"strength": strength,
		"agility": agility,
		"intuition": intuition,
		"endurance": endurance,
		"arcane": arcane
	}

# Set attributes from a dictionary
func set_attributes(attrs):
	strength = attrs.get("strength", 3)
	agility = attrs.get("agility", 3)
	intuition = attrs.get("intuition", 3)
	endurance = attrs.get("endurance", 3)
	arcane = attrs.get("arcane", 3)
	calculate_all_stats()

# Get current stats for display/debug
func get_stats_summary():
	return {
		"attributes": get_attributes(),
		"health": str(current_health) + "/" + str(max_health),
		"mana": str(current_mana) + "/" + str(max_mana),
		"physical_damage": physical_damage,
		"critical_chance": critical_chance,
		"evasion_chance": evasion_chance,
		"carry_weight": carry_weight,
		"health_regen": health_regen,
		"mana_regen": mana_regen
	}

# Restore health and mana to full (for level ups)
func restore_health_and_mana():
	current_health = max_health
	current_mana = max_mana
	emit_signal("health_changed")
	emit_signal("mana_changed")