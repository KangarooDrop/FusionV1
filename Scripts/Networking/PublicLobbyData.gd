extends Control

var joinButton
var usernameLabel
var keyLabel
var playersLabel
var infoLabel

var buffer = 16

func initInfo(username : String, roomKey : String, playersString : String, info : String, lengths : Array = [64, 128, 64, 64, 256]):
	if lengths.size() != 5:
		print("Error loading public lobby data, freeing")
		queue_free()
	else:
		var total = buffer
		for l in lengths:
			total += l + buffer
		
		joinButton = $Button
		joinButton.rect_min_size.x = lengths[0]
		joinButton.rect_size.x = 0
		joinButton.rect_position.x = buffer
		
		usernameLabel = $UsernameLabel
		usernameLabel.text = username
		usernameLabel.rect_min_size.x = lengths[1]
		usernameLabel.rect_size.x = 0
		usernameLabel.rect_position.x = joinButton.rect_position.x + lengths[0] + buffer
		
		keyLabel = $KeyLabel
		keyLabel.text = roomKey
		keyLabel.rect_min_size.x = lengths[2]
		keyLabel.rect_size.x = 0
		keyLabel.rect_position.x = usernameLabel.rect_position.x + lengths[1] + buffer
		
		playersLabel = $PlayersLabel
		playersLabel.text = playersString
		playersLabel.rect_min_size.x = lengths[3]
		playersLabel.rect_size.x = 0
		playersLabel.rect_position.x = keyLabel.rect_position.x + lengths[2] + buffer
		
		infoLabel = $InfoLabel
		infoLabel.text = info
		infoLabel.rect_min_size.x = lengths[4]
		infoLabel.rect_size.x = 0
		infoLabel.rect_position.x = playersLabel.rect_position.x + lengths[3] + buffer
		
		rect_min_size = Vector2(total, 23)
		rect_size = Vector2()
