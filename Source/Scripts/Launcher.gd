extends Node

## The URL of the config JSON file.
@export var config_url:String
## The launcher font.
@export var font:Font
## The launcher window icon.
@export var icon:Texture2D
## The launcher background image.
@export var thumbnail:Texture2D

@export_category("Nodes")
@export var theme:Theme
@export var thumbnail_rect:TextureRect
@export var log_label:Label
@export var progress_bar:ProgressBar
@export var choice_box:Panel
@export var message_label:Label
@export var retry_button:Button
@export var quit_button:Button

var File := preload("res://Scripts/File.gd")

var choice:int
var download_result:int

const game_temp_path:String = "Game.tmp"
const config_temp_path:String = "Config.tmp"
const game_directory:String = "Game"
const version_path:String = "Game/Version"

func _enter_tree()->void:
	# Set custom font, icon and thumbnail
	if font != null: theme.default_font = font #end
	if icon != null: DisplayServer.set_icon(icon.get_image()) #end
	if thumbnail != null: thumbnail_rect.texture = thumbnail #end
#end

func _exit_tree()->void:
	# Delete temporary files
	File.delete(config_temp_path)
	File.delete(game_temp_path)
#end

func _ready()->void:
	# Fetch config
	display("FETCHING_CONFIG")
	await download(config_url, config_temp_path, false)
	var config:Dictionary = JSON.parse_string(File.read(config_temp_path))
	File.delete(config_temp_path)
	display()
	
	# Ensure config received
	if config == null:
		await display_error("FAILED_FETCH_CONFIG")
		return
	#end
	
	# Get current version number
	var current_version:String = File.read(version_path)
	# Get latest version number
	var latest_version:String = config.get("version")
	if latest_version == null:
		await display_error("MISSING_VERSION")
		return
	#end
	# Download latest version if outdated
	if current_version != latest_version:
		# Get download URL
		var download_url:String = config.get(str(platform_name(), "_url"))
		if download_url == null:
			await display_error("MISSING_DOWNLOAD_URL")
			return
		#end
		# Download latest file
		var download_success:Error = await download(download_url, game_temp_path, true)
		if download_success != OK:
			await display_error("FAILED_DOWNLOAD")
			return
		#end
		# Extract latest file
		display("EXTRACTING")
		await get_tree().process_frame
		File.extract(game_temp_path, game_directory)
		display()
		await get_tree().process_frame
		# Delete temporary file
		File.delete(game_temp_path)
		# Store latest version in downloaded directory
		File.write(version_path, latest_version)
	#end
	
	# Get download exe path
	var download_exe_path:String = config.get(str(platform_name(), "_exe"))
	if download_exe_path == null:
		await display_error("MISSING_DOWNLOAD_EXE")
		return
	#end
	# Run game executable
	var launch_success:int = OS.create_process(game_directory.path_join(download_exe_path), [
		"--",
		str("--launcher_path=", OS.get_executable_path()),
		str("--launcher_config_url=", config_url),
		str("--launcher_game_version=", latest_version),
	])
	if launch_success < 0:
		await display_error("FAILED_LAUNCH")
		return
	#end
	
	# Close launcher
	get_tree().quit()

func download(link:String, path:String, show_progress:bool)->Error:
	# Create HTTP request
	var http := HTTPRequest.new()
	http.download_file = path
	http.use_threads = true
	add_child(http)
	
	# Request file
	var success:Error = http.request(link)
	# Ensure request was successful
	if success != OK:
		return success
	#end
	
	# Set download result when request completed
	download_result = -1
	http.request_completed.connect(func(result:int, _response_code:int, _headers:PackedStringArray, _body:PackedByteArray)->void:
		download_result = result)
	
	# Show progress bar
	progress_bar.value = 0
	if show_progress:
		progress_bar.show()
	#end
	# Update progress bar while downloading
	while download_result < 0:
		# Get download progress
		var current_bytes:int = http.get_downloaded_bytes()
		var total_bytes:int = http.get_body_size()
		# Display download progress
		if total_bytes >= 0:
			progress_bar.value = lerp(progress_bar.value, float(current_bytes) / total_bytes, 0.1)
		#end
		# Wait for next frame
		await get_tree().process_frame
	#end
	# Hide progress bar
	progress_bar.value = 1
	progress_bar.hide()
	
	# Destroy HTTP request
	http.queue_free()
	# Return success
	return download_result as Error

func display(text:String = "")->void:
	log_label.text = text
#end

func display_error(text:String)->void:
	message_label.text = text
	choice_box.show()
	
	choice = -1
	var retry := func()->void:
		choice = 0
	#end
	var quit := func()->void:
		choice = 1
	#end
	retry_button.pressed.connect(retry)
	quit_button.pressed.connect(quit)
	
	while choice < 0:
		await get_tree().process_frame
	#end
	
	retry_button.pressed.disconnect(retry)
	quit_button.pressed.disconnect(quit)
	
	choice_box.hide()
	message_label.text = ""
	
	match choice:
		0: get_tree().reload_current_scene()
		1: get_tree().quit()
	#end
#end

func platform_name()->String:
	if OS.has_feature("windows"):
		return "windows"
	elif OS.has_feature("macos"):
		return "macos"
	elif OS.has_feature("linux"):
		return "linux"
	elif OS.has_feature("android"):
		return "android"
	elif OS.has_feature("ios"):
		return "ios"
	elif OS.has_feature("web"):
		return "web"
	else:
		return ""
	#end
#end
