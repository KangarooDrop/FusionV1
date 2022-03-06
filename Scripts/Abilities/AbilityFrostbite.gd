extends Ability

class_name AbilityFrostbite

func _init(card : Card).("Frostbite", "Inflicts " + str(AbilityFrozen.new(null)) + " on the enemy creature when this creature attacks or is attacked", card, Color.blue, false, Vector2(0, 32)):
	pass
	
func onAttack(blocker, board):
	if is_instance_valid(blocker.cardNode):
		var frozen = AbilityFrozen.new(blocker.cardNode.card)
		frozen.onEffect()
		blocker.cardNode.card.abilities.append(frozen)
	
func onBeingAttacked(attacker, board):
	if is_instance_valid(attacker.cardNode):
		var frozen = AbilityFrozen.new(attacker.cardNode.card)
		frozen.onEffect()
		attacker.cardNode.card.abilities.append(frozen)
