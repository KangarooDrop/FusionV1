extends Node2D


#"user://decks/" + fileName + ".json"

func writeToJSON(path : String, fileName : String, data : Dictionary, makeFolders = false) -> int:
	
	if makeFolders:
		var directory = Directory.new( )
		directory.make_dir_recursive(path)
	
	var file = File.new()
	var error = file.open(path + "/" + fileName + ".json", File.WRITE)
	if error != 0:
		#print("ERROR: writing to file at path " + path + "/" + fileName + "  :  " + str(error))
		
		if not makeFolders:
			var errorNew = writeToJSON(path, fileName, data, true)
			return errorNew
		else:
			return error
		
	file.store_string(JSON.print(data, "  "))
	file.close()
	
	return 0

func readJSON(path : String) -> Dictionary:
	var file := File.new()
	var dict : Dictionary
	var text
	if file.file_exists(path):
		file.open(path, file.READ)
		text = file.get_as_text()
		var par = parse_json(text)
		if par != null:
			dict = par
		else:
			MessageManager.notify("Error parsing deck save file")
		file.close()
	return dict

func dumpDataLog(gameLog : Array, makeFolders = false) -> int:
	var path = "user://dumps/"
	var fileName = "game_dump_" + str(randi())  +".txt"
	
	if makeFolders:
		var directory = Directory.new( )
		directory.make_dir_recursive(path)
	
	var file = File.new()
	var error = file.open(path + fileName, File.WRITE)
	if error != 0:
		if not makeFolders:
			var errorNew = dumpDataLog(gameLog, true)
			return errorNew
		else:
			print("ERROR DUMPING GAME LOG")
			return error
		
	
	for i in range(gameLog.size()):
		var string = gameLog[i]
		if i != gameLog.size() - 1:
			string += "\n"
		file.store_string(string)
		
	file.close()
	
	return 0
