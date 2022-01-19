extends Ability

class_name AbilityFrostbite

func _init(card : Card).("Frostbite", "Inflicts Frozen on the enemy creature when this creature attacks or is attacked", card):
	pass
	
func onAttack(blocker, board):
	blocker.card.abilities.append(AbilityFrozen.new(blocker.card))
	
func onBeingAttacked(attacker, board):
	attacker.card.abilities.append(AbilityFrozen.new(attacker.card))
