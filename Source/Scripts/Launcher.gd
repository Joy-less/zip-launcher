extends Node

## The URL of the version string.
@export var version_url:String
## The launcher font.
@export var font:Font
## The launcher window icon.
@export var icon:Texture2D
## The launcher background image.
@export var thumbnail:Texture2D
@export_category("Windows")
## The URL of the Windows game zip.
@export var windows_url:String
## The path to the executable in the Windows game zip.
@export var windows_exe:String = "Game.exe"
@export_category("macOS")
## The URL of the macOS game zip.
@export var macos_url:String
## The path to the executable in the macOS game zip.
@export var macos_exe:String = "Game.app"
@export_category("Linux")
## The URL of the Linux game zip.
@export var linux_url:String
## The path to the executable in the Linux game zip.
@export var linux_exe:String = "Game.x86_64"
@export_category("Android")
## The URL of the Android game zip.
@export var android_url:String
## The path to the executable in the Android game zip.
@export var android_exe:String = "Game.apk"
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
var http:HTTPRequest
var choice:int
var download_result:int

const game_temp_path := "Game.tmp"
const version_temp_path := "Version.tmp"
const game_directory := "Game"
const version_path := "Game/Version"

func _enter_tree():
	# Set custom font, icon and thumbnail
	if font != null: theme.default_font = font #end
	if icon != null: DisplayServer.set_icon(icon.get_image()) #end
	if thumbnail != null: thumbnail_rect.texture = thumbnail #end
#end

func _exit_tree():
	# Delete temporary files
	File.delete(version_temp_path)
	File.delete(game_temp_path)
#end

func _ready():
	# Get latest version number
	display("FETCHING_VERSION")
	await download(version_url, version_temp_path, false)
	var latest_version:String = File.read(version_temp_path).strip_edges()
	File.delete(version_temp_path)
	display()
	
	# Ensure latest version number received
	if latest_version == null:
		await display_error("FAILED_FETCH_VERSION")
		return
	#end
	
	# Get current version number
	var current_version = File.read(version_path)
	# Download latest version if outdated
	if current_version != latest_version:
		# Download latest file
		var download_success:int = await download(download_url(), game_temp_path, true)
		# Ensure latest file downloaded
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
	
	# Run game executable
	var launch_success:int = OS.create_process(game_directory.path_join(exe_path()), [
		"--",
		"--launcher_path=" + OS.get_executable_path(),
		"--launcher_game_version_url=" + version_url,
		"--launcher_game_version=" + latest_version,
	])
	
	# Ensure game executable ran successfully
	if launch_success == -1:
		await display_error("FAILED_LAUNCH")
		return
	#end
	
	# Close launcher
	get_tree().quit()

func download(link:String, path:String, show_progress:bool) -> Error:
	# Create HTTP request
	http = HTTPRequest.new()
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
	http.request_completed.connect(func(result, _response_code, _headers, _body):
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
	return OK if download_result == OK else FAILED

func display(text:String = "") -> void:
	log_label.text = text
#end

func display_error(text:String) -> void:
	message_label.text = text
	choice_box.show()
	
	choice = -1
	var retry := func(): choice = 0
	var quit := func(): choice = 1
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

func download_url() -> String:
	match OS.get_name().to_lower():
		"windows": return windows_url
		"macos": return macos_url
		"linux", "freebsd", "netbsd", "openbsd", "bsd": return linux_url
		"android": return android_url
		_: return ""
	#end
#end

func exe_path() -> String:
	match OS.get_name().to_lower():
		"windows": return windows_exe
		"macos": return macos_exe
		"linux", "freebsd", "netbsd", "openbsd", "bsd": return linux_exe
		"android": return android_exe
		_: return ""
	#end
#end
