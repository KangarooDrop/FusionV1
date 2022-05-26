extends Control

var fadingNode
var lineEdit
var button
var vbox
var scrollContainer

var messageTimer = 0

func _ready():
	fadingNode = $FadingNode
	lineEdit = $LobbyChat/LobbyChat/LineEdit4
	button = $LobbyChat/LobbyChat/SendChatButton
	vbox = $LobbyChat/LobbyChat/ScrollContainer2/VBoxContainer
	scrollContainer = $LobbyChat/LobbyChat/ScrollContainer2
	
	fadingNode.maxTime = 0.1
	fadingNode.freeOnFadeOut = false
	fadingNode.maxAlpha = 0.85
	fadingNode.connect("onFadeIn", self, "onFadeIn")
	fadingNode.connect("onFadeOut", self, "onFadeOut")

func onFadeIn():
	lineEdit.grab_focus()

func _physics_process(delta):
	visible = modulate.a > 0
	if messageTimer > 0:
		messageTimer -= delta

func sendMessage(text = null):
	if text == null:
		text = lineEdit.text
		
	if messageTimer >= 3:
		MessageManager.createPopup("Warning", "Slow down there, buckaroo! You're sending messages way too fast")
		return
	
	if text == "":
		return
	
	messageTimer += 1
	Server.sendChat(SilentWolf.Auth.logged_in_player + ": " + text)
	lineEdit.text = ""

func addMessage(message):
	var label = Label.new()
	NodeLoc.setLabelParams(label)
	label.text = message
	
	vbox.add_child(label)
	var scrollToBottom = (scrollContainer.get_v_scrollbar().max_value - scrollContainer.rect_size.y) - scrollContainer.scroll_vertical < 3
	if scrollToBottom:
		yield(get_tree(), "idle_frame")
		scrollContainer.scroll_vertical = scrollContainer.get_v_scrollbar().max_value
