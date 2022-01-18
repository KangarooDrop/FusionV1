extends Node2D

var deckDisplayData = preload("res://Scenes/UI/DeckDisplayData.tscn")

var data := []
var total := -1 setget setTotal, getTotal
var deckMax = 20

func setTotal(newTotal : int):
	if newTotal != total:
		total = newTotal
		$Label.text = str(newTotal) + " / " + str(deckMax)
		get_parent().deckModified()
		
		if total != deckMax:
			$Label.set("custom_colors/font_color", Color.black)
		else:
			$Label.set("custom_colors/font_color", Color.blueviolet)
	
func getTotal() -> int:
	return total

func _ready():
	setTotal(0)

func clearData():
	while(data.size() > 0):
		removeCard(0)

func addCard(id : int) -> bool:
	for i in range(data.size()):
		if data[i].card.UUID == id:
			if data[i].count <= 3:
				data[i].count += 1
				data[i].updateDisplay()
				setTotal(getTotal() + 1)
				return true
			return false
			
	var d = deckDisplayData.instance()
	d.card = ListOfCards.getCard(id)
	d.count = 1
	$VBoxContainer.add_child(d)
	data.append(d)
	d.get_node("Button").connect("pressed", self, "onDeckDataClicked", [d])
	setTotal(getTotal() + 1)
	return true
	
func removeCard(index : int) -> bool:
	if index >= 0 and index < data.size():
		if data[index].count > 1:
			data[index].count -= 1
			data[index].updateDisplay()
		else:
			data[index].queue_free()
			data.remove(index)
			#$VBoxContainer.rect_position.y = 0
			#$VBoxContainer.rect_size.y = 0
		setTotal(getTotal() - 1)
		return true
	return false

func onDeckDataClicked(d) -> bool:
	var index = -1
	for i in range(data.size()):
		if data[i] == d:
			index = i
			break
	if index != null:
		return removeCard(index)
	else:
		return false

func getDeckData() -> Dictionary:
	var rtn = {}
	for d in data:
		rtn[d.card.UUID] = d.count
	return rtn

func getDeckDataAsJSON() -> Dictionary:
	var rtn = {}
	var data = getDeckData()
	for d in data.keys():
		rtn[str(d)] = float(data[d])
	return rtn
