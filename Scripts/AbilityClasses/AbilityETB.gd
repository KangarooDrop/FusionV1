extends Ability

class_name AbilityETB

var timesApplied = 0

func _init(name : String, card : Card, c : Color, showCount : bool, iconPos : Vector2).(name, card, c, showCount, iconPos):
	pass

func onEnter(slot):
	.onEnter(slot)
	if timesApplied < count:
		onApplied(slot)
		timesApplied = count
	
func onEnterFromFusion(slot):
	.onEnterFromFusion(slot)
	if timesApplied < count:
		onApplied(slot)
		timesApplied = count

func onApplied(slot):
	pass

func onLeave():
	timesApplied = 0

func clone(card : Card) -> Ability:
	var abl = .clone(card)
	abl.timesApplied = timesApplied
	return abl

func genDescription(subCount = 0):
	return .genDescription(timesApplied)

func combine(abl : Ability):
	.combine(abl)
	timesApplied += abl.timesApplied
