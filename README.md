![Banner](https://github.com/Joy-less/zip-launcher/blob/7ed04ac8a72e91d7ff693c9f716e992ff2d0890c/Assets/Banner%204x.png)

# zip::launcher

A customisable game launcher and auto updater made in Godot.

It downloads the latest game version if necessary and runs your game.

## Example

![Launcher Preview](https://github.com/Joy-less/zip-launcher/blob/acb201823d8898e7b4fe786a4770db498610075b/Assets/LauncherPreview.jpg)

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

The file should be in the format:
```json
{
  // Required
  "version": "The version number. Update this every time you update any of your game releases.",

  // Optional
  "windows_url": "The URL of the Windows game zip.",
  "windows_exe": "The path to the executable in the Windows game zip.",
  "linux_url": "The URL of the Linux game zip.",
  "linux_exe": "The path to the executable in the Linux game zip.",
  "macos_url": "The URL of the macOS game zip.",
  "macos_exe": "The path to the executable in the macOS game zip.",
  "android_url": "The URL of the Android game zip.",
  "android_exe": "The path to the executable in the Android game zip.",
  "ios_url": "The URL of the iOS game zip.",
  "ios_exe": "The path to the executable in the iOS game zip.",
  "web_url": "The URL of the Web game zip.",
  "web_exe": "The path to the executable in the Web game zip."
}
```

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