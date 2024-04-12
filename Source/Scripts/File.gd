extends Object

static func read(path : String):
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return null
	return file.get_as_text()

static func write(path : String, data : String) -> void:
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(data)

static func delete(path : String) -> void:
	DirAccess.open(".").remove(path)

static func extract(path : String, directory : String):
	# Open zip file
	var zip_reader := ZIPReader.new()
	if zip_reader.open(path) != OK:
		return
	
	# Create target directory
	DirAccess.make_dir_recursive_absolute(directory)
	
	# Get each nested zipped file
	for file_path in zip_reader.get_files():
		# Create target sub directory
		DirAccess.open(directory).make_dir_recursive(file_path.get_base_dir())
		# Create target file
		var target_file := FileAccess.open(directory.path_join(file_path), FileAccess.WRITE)
		# Extract zipped file to target file
		if target_file != null:
			target_file.store_buffer(zip_reader.read_file(file_path))
