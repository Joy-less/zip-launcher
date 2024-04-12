![Banner](https://github.com/Joy-less/zip-launcher/blob/7ed04ac8a72e91d7ff693c9f716e992ff2d0890c/Assets/Banner%204x.png)

# zip::launcher

A customisable game launcher and auto updater made in Godot.

It checks if the current version of the game is the latest, downloads the latest version, and runs your game.

## Example

![Launcher Preview](https://github.com/Joy-less/zip-launcher/blob/acb201823d8898e7b4fe786a4770db498610075b/Assets/LauncherPreview.jpg)

## Notes

- The links must be direct download links, not supported by Google Drive or OneDrive. GitHub is recommended.
- The launcher downloads the entire game zip, even if the update is small.
- The first argument of the launched game is the path of the launcher, useful for reopening the launcher.

## Setup

1. Upload your zipped game builds to a file host such as GitHub.

2. Download and open the zip::launcher project in Godot.

3. Open the Main scene and select the Launcher node.

![Configuration Preview](https://github.com/Joy-less/zip-launcher/blob/be0614f244a512743ec303712e1dc8ae5c17e2d3/Assets/ConfigPreview.png)

4. Set the Version URL to a link to a text file containing a version. You should increment this version every time you update any of your game releases.

5. Set the platform URLs to links containing your latest zipped game builds.

6. Set the platform EXEs to the paths of your executables to launch.

7. Set the Font, Icon and Thumbnail to your custom resources. To set the icon shown in the file explorer, open Project Settings and set `application/config/icon`.

8. Export the launcher for each platform.
