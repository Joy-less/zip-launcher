## Reads the file as a UTF-8 string.
static func read(path:String)->String:
	return FileAccess.get_file_as_string(path)
#end

## Reads the file as a UTF-8 string and parses a JSON element.
static func read_json(path:String)->Variant:
	var text:String = read(path)
	if text.is_empty():
		return null
	#end
	return JSON.parse_string(text)
#end

## Writes the UTF-8 string to the file.
static func write(path:String, data:String)->void:
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(data)
#end

## Serializes the JSON element as a UTF-8 string and writes it to the file.
static func write_json(path:String, data:Variant, indent:String = "")->void:
	write(path, JSON.stringify(data, indent))
#end

## Deletes the file.
static func delete(path:String)->void:
	DirAccess.open(".").remove(path)
#end

## Extracts the ZIP file to the directory.
static func extract(path:String, directory:String)->void:
	# Open zip file
	var zip_reader := ZIPReader.new()
	if zip_reader.open(path) != OK:
		return
	#end
	
	# Create target directory
	DirAccess.make_dir_recursive_absolute(directory)
	
	# Get each nested zipped file
	for file_path:String in zip_reader.get_files():
		# Create target sub directory
		DirAccess.open(directory).make_dir_recursive(file_path.get_base_dir())
		# Create target file
		var target_file := FileAccess.open(directory.path_join(file_path), FileAccess.WRITE)
		# Extract zipped file to target file
		if target_file != null:
			target_file.store_buffer(zip_reader.read_file(file_path))
		#end
	#end
#end
