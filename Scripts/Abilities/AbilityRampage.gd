extends Ability

class_name AbilityRampage

func _init(card : Card).("Rampage", card, Color.brown, false,Vector2(0, 64)):
	pass

func onDealDamage(slot):
	if is_instance_valid(slot.cardNode) and slot.cardNode.card.toughness < 0:
		for p in NodeLoc.getBoard().players:
			if p.UUID == slot.playerID:
				p.takeDamage(-slot.cardNode.card.toughness, card)

func genDescription() -> String:
	return .genDescription() + "When attacking a creature, excess damage is dealt to its owner"
