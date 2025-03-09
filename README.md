![Banner](https://github.com/Joy-less/zip-launcher/blob/main/Assets/Banner%204x.png?raw=true)

# zip::launcher

A customisable game launcher and auto updater made in Godot.

It downloads the latest game version if necessary and runs your game.

## Example

![Launcher Preview](https://github.com/Joy-less/zip-launcher/blob/main/Assets/LauncherPreview.jpg?raw=true)

## Notes

- The links must be direct downloads (not supported by Google Drive or OneDrive).
- The launcher downloads the entire game zip, even if the update is small.
- The launcher passes command line arguments to your game:
  - `--launcher_path={path}` - path of launcher executable
  - `--launcher_game_version_url={url}` - URL of game version
  - `--launcher_game_version={version}` - launched game version

## Setup

1. Upload your zipped game builds to a file host such as GitHub Releases.

2. Download and open the zip::launcher project in Godot.

3. Open the Main scene and select the Launcher node.

![Configuration Preview](https://github.com/Joy-less/zip-launcher/blob/main/Assets/ConfigPreview.png?raw=true)

4. Set the Config URL to a link to a JSON file.

The file should have the keys:
- `version`: The version number. Update this every time you update any of your game releases.
- `windows_url`, `linux_url`, `macos_url`, `android_url`, `ios_url`, `web_url`: The URL of each platform's game zip.
- `windows_exe`, `linux_exe`, `macos_exe`, `android_exe`, `ios_exe`, `web_exe`: The path to the executable in each platform's game zip.

Example config file:
```json
{
  "version": "1",
  "windows_url": "https://example.com/download/windows.zip",
  "windows_exe": "Game.exe",
  "linux_url": "https://example.com/download/linux.zip",
  "linux_exe": "Game.x86_64",
  "macos_url": "https://example.com/download/macos.zip",
  "macos_exe": "Game.app",
  "android_url": "https://example.com/download/android.zip",
  "android_exe": "Game.apk"
}
```

5. Set the Font, Icon and Thumbnail to your custom resources. To set the icon shown in the file explorer, open Project Settings and set `application/config/icon`.

6. Export the launcher for each desired platform.