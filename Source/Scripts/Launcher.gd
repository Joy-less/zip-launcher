extends Node

## The URL of a file containing the latest version number.
@export var version_url : String
## The launcher font.
@export var font : Font
## The launcher window icon.
@export var icon : Image
## The launcher background image.
@export var thumbnail : Texture2D
@export_category("Windows")
## The URL of the Windows game zip.
@export var windows_url : String
## The path to the executable in the Windows game zip.
@export var windows_exe : String = "Game.exe"
@export_category("macOS")
## The URL of the macOS game zip.
@export var macos_url : String
## The path to the executable in the macOS game zip.
@export var macos_exe : String = "Game.app"
@export_category("Linux")
## The URL of the Linux game zip.
@export var linux_url : String
## The path to the executable in the Linux game zip.
@export var linux_exe : String = "Game.x86_64"
@export_category("Android")
## The URL of the Android game zip.
@export var android_url : String
## The path to the executable in the Android game zip.
@export var android_exe : String = "Game.apk"
@export_category("Nodes")
@export var theme : Theme
@export var thumbnail_rect : TextureRect
@export var log_label : RichTextLabel
@export var progress_bar : ProgressBar
@export var choice_box : Panel
@export var message_label : RichTextLabel
@export var retry_button : Button
@export var quit_button : Button

var File := preload("res://Scripts/File.gd")
var http : HTTPRequest
var choice : int

const game_temp_path := "Game.tmp"
const version_temp_path := "Version.tmp"
const game_directory := "Game"
const version_path := "Game/Version"

func _enter_tree():
	# Set custom font, icon and thumbnail
	if font != null: theme.default_font = font
	if icon != null: DisplayServer.set_icon(icon)
	if thumbnail != null: thumbnail_rect.texture = thumbnail

func _ready():
	# Get latest version number
	display(tr("FETCHING_VERSION"))
	await download(version_url, version_temp_path)
	var latest_version = File.read(version_temp_path)
	File.delete(version_temp_path)
	display()
	
	# Ensure latest version number received
	if latest_version == null:
		await show_choice_box(tr("FAIL_FETCH_VERSION"))
		return
	
	# Get current version number
	var current_version = File.read(version_path)
	# Download latest version if outdated
	if current_version != latest_version:
		# Show progress bar
		progress_bar.value = 0
		progress_bar.show()
		# Download latest file
		await download(windows_url, game_temp_path)
		# Extract latest file
		File.extract(game_temp_path, game_directory)
		# Store latest version in downloaded directory
		File.write(version_path, latest_version)
		# Delete temporary file
		File.delete(game_temp_path)
		# Hide progress bar
		progress_bar.hide()
	
	# Run game executable
	var launcher_path := OS.get_executable_path()
	var launch_success := OS.create_process(
		game_directory.path_join(get_exe_path()),
		["--launcher_path=" + launcher_path]
	)
	
	# Ensure game executable ran successfully
	if launch_success != OK:
		await show_choice_box(tr("FAIL_LAUNCH"))
		return
	
	# Close launcher
	get_tree().quit()

func _process(_delta):
	if is_instance_valid(http):
		# Get download progress
		var current_bytes := http.get_downloaded_bytes()
		var total_bytes := http.get_body_size()
		# Display download progress
		if total_bytes >= 0:
			progress_bar.value = lerp(progress_bar.value, float(current_bytes) / total_bytes, 0.1)

func download(link : String, path : String) -> Error:
	# Create HTTP request
	http = HTTPRequest.new()
	http.download_file = path
	http.use_threads = true
	add_child(http)
	
	# Request file
	var success = http.request(link)
	# Ensure request was successful
	if success != OK:
		return success
	
	# Wait for download completion
	await http.request_completed
	# Destroy HTTP request
	http.queue_free()
	# Return success
	return OK

func display(text = null) -> void:
	if text != null:
		log_label.text = "[center]" + str(text)
		log_label.show()
	else:
		log_label.hide()
		log_label.text = ""

func show_choice_box(text : String) -> void:
	message_label.text = "[center]\n" + text
	choice_box.show()
	
	choice = -1
	var retry := func(): choice = 0
	var quit := func(): choice = 1
	retry_button.pressed.connect(retry)
	quit_button.pressed.connect(quit)
	
	while choice < 0:
		await get_tree().process_frame
	
	retry_button.pressed.disconnect(retry)
	quit_button.pressed.disconnect(quit)
	
	choice_box.hide()
	message_label.text = ""
	
	match choice:
		0: get_tree().reload_current_scene()
		1: get_tree().quit()

func get_download_url() -> String:
	match OS.get_name().to_lower():
		"windows": return windows_url
		"macos": return macos_url
		"linux", "FreeBSD", "NetBSD", "OpenBSD", "BSD": return linux_url
		"android": return android_url
		_: return ""

func get_exe_path() -> String:
	match OS.get_name().to_lower():
		"windows": return windows_exe
		"macos": return macos_exe
		"linux", "FreeBSD", "NetBSD", "OpenBSD", "BSD": return linux_exe
		"android": return android_exe
		_: return ""
