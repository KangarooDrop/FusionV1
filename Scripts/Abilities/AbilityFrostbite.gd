extends Ability

class_name AbilityFrostbite

func _init(card : Card).("Frostbite", "Inflicts Frozen on the enemy creature when this creature attacks or is attacked", card):
	pass
	
func onAttack(blocker, board):
	if is_instance_valid(blocker.cardNode):
		blocker.cardNode.card.abilities.append(AbilityFrozen.new(blocker.cardNode.card))
	
func onBeingAttacked(attacker, board):
	if is_instance_valid(attacker.cardNode):
		attacker.cardNode.card.abilities.append(AbilityFrozen.new(attacker.cardNode.card))
