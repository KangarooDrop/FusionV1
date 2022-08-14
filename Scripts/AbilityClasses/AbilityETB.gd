extends Ability

class_name AbilityETB

func _init(name : String, card : Card, c : Color, showCount : bool, iconPos : Vector2).(name, card, c, showCount, iconPos):
	myVars["timesApplied"] = 0

func onEnter(slot):
	.onEnter(slot)
	if myVars.timesApplied < myVars.count:
		onApplied(slot)
	
func onEnterFromFusion(slot):
	.onEnterFromFusion(slot)
	if myVars.timesApplied < myVars.count:
		onApplied(slot)

func onApplied(slot):
	pass

func onLeave():
	myVars.timesApplied = 0

func genDescription(subCount = 0):
	return .genDescription(myVars.timesApplied)

func combine(abl : Ability):
	.combine(abl)
	myVars.timesApplied += abl.myVars.timesApplied
