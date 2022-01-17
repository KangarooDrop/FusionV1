extends Node

var lastUUID = -1
var abilityList := []

func _ready():
	addAbility(Ability.new("Dash", "This creature can attack the turn it is played"))
	addAbility(Ability.new("Wisedom", "This creature draws a card when entering the board"))
	addAbility(Ability.new("Tough", "This creature gains +1/+1 when attacked"))
	addAbility(Ability.new("Production", "This creature create a mech at the start of your turn"))
	addAbility(Ability.new("Sacrifice", "This creature gives your other creatures on board +1/+1 when it dies"))
	
	for i in range(abilityList.size()):
		print(abilityList[i].UUID, ":  ", abilityList[i].name)
	
func addAbility(abl : Ability):
	lastUUID += 1
	abl.UUID = lastUUID
	abilityList.append(abl)
