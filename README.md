# wix_flutter

A Flutter project to test build automation with [Just](https://just.systems/) ([Github](https://github.com/casey/just)) both locally and on a remote task runner like GitHub actions.

## Requirements

This project assumes that you are running on a Windows system with the following tools installed and available on your system:

1. `just` for the task runner
2. [Powershell](https://learn.microsoft.com/en-us/powershell/) ([Github](https://github.com/PowerShell/PowerShell)) as the shell on Windows. Bash is used on Linux.
3. [Flutter](https://flutter.dev/) SDK
4. [Android Studio](https://developer.android.com/studio/) and the corrosponding Android SDK for Android builds (.apk, .aab)
5. [Visual Studio](https://visualstudio.microsoft.com/) and the corrosponding Windows SDK for Windows builds (.exe)
6. [WiX Toolset](https://wixtoolset.org/) to build Windows installer (.msi). This must ideally be present in PATH, but a local location can also be used provided it is mentioned in the `Justfile`.

	This project is configured for [Visual Studio 2022](https://visualstudio.microsoft.com/downloads/) Community Edition. Using other versions may require additional configuration and adjustments to the `Justfile`.

	For Linux dependencies, refer to the Dockerfile present alongside this README.

7. [Docker](https://www.docker.com/)

	Docker is used for Linux builds of this project. An active internet connection may be required during runs to build the images required for the builds to run.

8. [WiX Toolset](https://wixtoolset.org/)

	The WiX Toolset is used to generate `.msi` installers for the Windows builds of this project.

In addition, the following tools were used when working on this project:

1. [Visual Studio Code](https://code.visualstudio.com/)

	The Editor of choice for this project. The following plugins were used for this project:

	1. [Flutter](https://marketplace.visualstudio.com/items?itemName=Dart-Code.flutter)
	2. [Dart](https://marketplace.visualstudio.com/items?itemName=Dart-Code.dart-code)
	3. [Docker](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-docker)
	4. [just](https://marketplace.visualstudio.com/items?itemName=skellock.just)

2. [Visual Studio 2022](https://visualstudio.microsoft.com/vs/)

	This IDE was mainly used to edit the WiX file (`.wxs`) that is used to generate the `.msi` installer of the Windows builds of this project. The follwing plugin were used for this purpose:

	1. [Wix Toolset Visual Studio 2022 Extension](https://marketplace.visualstudio.com/items?itemName=WixToolset.WixToolsetVisualStudio2022Extension)

		For autocomplete, syntax highlighting and other IDE features for `.wxs` files

## About Just

Just is a simple build automation tool that simplifies running build commands. The commands are broken into *recipes* that can be individually invoked.

## Basic Recipes

All build outputs will be in the `/build` folder. All builds are completely portable. None of the builds have obfuscation enabled. Most builds have symbols seperated and stored in `/build/symbols`.

1. Linux:
	```
	just build-linux
	```
	The entire `/build/linux/` folder can be zipped and shipped for use.

2. Windows:
	```
	just build-exe
	```
	The entire `/build/windows/runner/Release` folder can be zipped and shipped for use.

	If an installer is desired, use
	```
	just build-msi
	```

3. Android:
	```
	just build-apk
	```
	The `/build/app/outputs/flutter-apk` folder will contain multiple APKs, split by architecture. These can be sideloaded onto a device of the appropriate architecture. Ship `app-<platform_arch>.apk` for use.

	If a more universally comaptible build is desired, use
	```
	just build-fat-apk
	```
	instead. Be warned that debug symbols are not split for these fat-apk builds. Ship `app-release.apk` for use.

	If an Android App Bundle (\*.aab) is desired, use
	```
	just build-aab
	```
	These formats are typically desired for app submissions in the Google Play Store / Amazon App Store.

4. Web
	```
	just build-web
	```
	These builds use Canvaskit as that seems to be the least buggy renderer of the two. Ship the contents of `/build/web` for use.

	If rare visual bugs are not a concern, use
	```
	just build-html-web
	```
	instead. This also provides a faster initial load time. Ship the contents of `/build/web` for use.

5. Miscellaneous Utilities
	```
	just regen-all
	```
	Use this to refresh all platform files (`/linux`, `/android`, `/windows`, `/web`), all built files (from `build_runner`, etc) and all dependencies. This can be useful when taking code from one platform to another or when wanting to start fresh.

	```
	just build-all
	```
	Use this to build the app for all platforms at once (Linux, Android, Windows, Web).

	Ship the contents of the following folders:

	* `/build/app/outputs/flutter-apk` for Android builds
	* `/build/windows/runner/Release` for Windows builds
	* `windows.msi` for installers of the Windows builds
	* `/build/linux/release/bundle` for Linux builds
	* `/build/web` for Flutter Web builds

	```
	just benchmark
	```
	Cleans all genreated files and caches and rebuilds all possible variants (Debug & Release, Canvaskit(Web), HTML(Web)) for all platforms (Linux, Android, Windows, Web). Under the hood, wraps `just build-all-variants` with a `Measure-Command` to provide a measure of the time taken at the end of the execution. Output is piped to `Out-Default` to ensure it is still echoed to the terminal. Remove the pipe if the output is not desireable.

	The outputs from this test are very similar to `just build-all`, with a few changes
	* All builds now have a debug variant built alongside the release variant. Android has `app.apk`, Windows has `/Debug` alongside `/Release`, Linux has `/debug` alongside `/release`, and Web has its builds split into `/web_release`, `/web_release_html`, and `/web_debug` inside the `/build` folder.

## Changes from the Norm

The aim of this repo is to use `just` to compress multi-step builds with multiple build arguments into a one line call.

The major files of significance are:

1. `Justfile`

	The `Justfile` is at the heart of this project. Invoke `just --list` or simply `just` in a terminal to obtain a list of all recipe in the project. To run a particular recipie, call `just <name-of-recipie>`. For detailed information about each reipie, refer to the comments in the `Justfile` itself.

	The recipe themselves are sorted by which features they interact with.

2. `Dockerfile` and related scripts (\*.ps1 & \*.sh)

	This is responsible for building the Linux image with Flutter SDK. The scripts provide and additional layer of convenience and ease of development.

	By default, it starts from `ubuntu:latest` and instals the Flutter SDK on top of it. If building a Snap package is desired, change the initial image by uncommenting/commenting to `snapcore/snapcraft:stable`. If building a Flatpak is desired, uncomment the relevant lines of code in the `Dockerfile`. AppImages are currently unsupported but may be supported in the future.

	Currently, there are no recipe to build Snaps and Flatpaks.

3. `windows.wxs` and other files in the `msi` folder

	These are the files used to generate the `.msi` installer for Windows builds of this project. The entire `windows.wxs` file is plain XML with comments and so can be edited with any compatible editor. For auto-complete and other comforts, use Visual Studio (2022 Community Edition used for this project) with the Wix Toolset Visual Studio Extension for your version of Visual Studio.

	To customise the installer, modify the files in the `msi\assets` folder while retaining the existing file formats/extensions. If `License.rtf` needs to be edited, preferably use something like `WordPad` for the purpose. The provided files use a custom backgorund color to show the extent to which the image is used in the UI.

	To view the default bitmaps used, see [this part](https://github.com/wixtoolset/wix3/tree/develop/src/ext/UIExtension/wixlib/Bitmaps) of the [source on Github](https://github.com/wixtoolset/wix3). For completion purposes, the default files are provided. The files are as follows:

	1. `dlgbmp.bmp`: Default for `dialog.bmp`
	2. `bannrbmp.bmp`: Default for `banner.bmp`
	3. `Licensertf.rtf`: Default for `License.rtf`

Other changes:

1. Added `/lib/build_runner_test/` and related dependencies

	This folder contains sample code to demonstrate orchestation of compile-time task runners.

	For this demo, the required dependencies were:

	1. `json_annotaion`
	2. `json_serializable` - dev
	3. `build_runner` -dev

	The resulting file is never imported anywhere in the project.

	If these files are desired to be removed, remove the files, the dependencies (from `pubspec.yaml`) and the corrosponding recipe as those have a hard dependency on `build_runner` in particular.

2. Added `google_fonts` folder with fonts

	This folder contains `Roboto-Regular.ttf` and its `LICENSE.txt`. This is included here to ensure that the Flutter Web builds made donot make a request to `gstatic.com` to request the font at runtime. This is especially useful for builds generated by `just build-fp-web` that result in a build which makes *zero* third-party requests by default.

	If removing this file is desired, then make sure to also remove the `fonts` key and all of its children from `pubspec.yaml`. Additionally, you may want to run `just rebuild` or simply `flutter pub get` after this is done.

## Potential Future Recipes

Recipes to build Snap, AppImage, Flatpak, MSIX, etc.

Automatic builds using Github Actions or something similar.