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

![Configuration Preview](https://github.com/Joy-less/zip-launcher/blob/be0614f244a512743ec303712e1dc8ae5c17e2d3/Assets/ConfigPreview.png)

4. Set the Version URL to a link to a text file containing a version. You should increment this version every time you update any of your game releases.

5. Set the platform URLs to links to your latest zipped game builds.

6. Set the platform EXEs to the paths of your executables to launch.

7. Set the Font, Icon and Thumbnail to your custom resources. To set the icon shown in the file explorer, open Project Settings and set `application/config/icon`.

8. Export the launcher for each platform.