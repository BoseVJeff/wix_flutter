# use PowerShell Core instead of sh:
set shell := ["pwsh.exe", "-c"]

VsDevShellDllPath:="C:/Program Files/Microsoft Visual Studio/2022/Community/Common7/Tools/Microsoft.VisualStudio.DevShell.dll"

default:
	just --list

#--------------------------------------------------------------------------------
#
#   __ _       _   _
#  / _| |     | | | |
# | |_| |_   _| |_| |_ ___ _ __
# |  _| | | | | __| __/ _ \ '__|
# | | | | |_| | |_| ||  __/ |
# |_| |_|\__,_|\__|\__\___|_|
#
# Art from https://ascii.co.uk/art/Flutter

#--------------------------------------------------------------------------------
# General Flutter Tools

# List all devices detetced by flutter
show-devices:
	flutter devices

# Use to clean and delete most generated code and files
clean:
	flutter clean

# Clean and regenerate code and files
rebuild: clean
	flutter pub get

# Clean android platform files
clean-android:
	rm -r .\android\

# Clean windows platform files
clean-windows:
	rm -r .\windows\
# Clean Web platform files
clean-web:
	rm -r .\web\

# Regenerate Android platform files
regen-android: clean-android
	flutter create . --platforms=android

# Regenerate Windows platform files
regen-windows: clean-windows
	flutter create . --platforms=windows

# Regenerate Web files
regen-web: clean-web
	flutter create . --platforms=web

# Regenerate all platform files
regen-all-platforms: clean-android clean-windows clean-web
	flutter create . --platforms=android,windows,web

# Clean and rebuild Dart codegen (json_serializable, freezed, etc using build_runner)
regen-dart:
	flutter pub run build_runner build --delete-conflicting-outputs

# Clean and regenerate all generated files in the project
regen-all: regen-all-platforms rebuild regen-dart

#--------------------------------------------------------------------------------

#           _           _
#          (_)         | |
# __      ___ _ __   __| | _____      _____
# \ \ /\ / / | '_ \ / _` |/ _ \ \ /\ / / __|
#  \ V  V /| | | | | (_| | (_) \ V  V /\__ \
#   \_/\_/ |_|_| |_|\__,_|\___/ \_/\_/ |___/
#
#
# Art from https://ascii.co.uk/art/windows

#--------------------------------------------------------------------------------
# Windows build commands
# These are assumend to run on a Windows platform

# Use this to import VS 2022 into the context. Exposes msbuild, etc to allow VS project automation
# Update this for different versions of Visual Studio
# Donot use this as a task dependency as context is lost between steps. USE FOR TESTING ONLY
import-vs-2022:
	Import-Module '{{VsDevShellDllPath}}' && Enter-VsDevShell 05870f35

# Build the release version of the app project (.sln) file from the Flutter CLI
build-sln-exe:
	flutter build windows --release --split-debug-info=build/app/outputs/symbols/windows

# Build the debug version of the app project (.sln) file from the Flutter CLI
build-sln-debug-exe:
	flutter build windows --debug

# Build the executable of the release version of the app
# Not using `import-vs-2022` here as context/imports are lost inbetween steps
build-vs-exe:
	Import-Module '{{VsDevShellDllPath}}' && Enter-VsDevShell 05870f35 -SkipAutomaticLocation &&  msbuild ./build/windows/wix_flutter.sln -property:Configuration=Release -property:Platform=x64

# Build the executable of the debug version of the app
# Not using `import-vs-2022` here as context/imports are lost inbetween steps
build-vs-debug-exe: import-vs-2022
	Import-Module '{{VsDevShellDllPath}}' && Enter-VsDevShell 05870f35 -SkipAutomaticLocation &&  msbuild ./build/windows/wix_flutter.sln -property:Configuration=Debug -property:Platform=x64

# Build .exe for release
build-exe: build-sln-exe build-vs-exe
	echo ".\build\windows\runner\Release\"

# Build .exe for debug
build-debug-exe: build-sln-debug-exe build-vs-debug-exe
	echo ".\build\windows\runner\Debug\"

#--------------------------------------------------------------------------------

#                  _           _     _
#                 | |         (_)   | |
#   __ _ _ __   __| |_ __ ___  _  __| |
#  / _` | '_ \ / _` | '__/ _ \| |/ _` |
# | (_| | | | | (_| | | | (_) | | (_| |
#  \__,_|_| |_|\__,_|_|  \___/|_|\__,_|
#
# Art from https://ascii.co.uk/art/android

#--------------------------------------------------------------------------------
# Android build commands
# Currently, upgrading AGP seems to require Android Studio GUI . This is true for android project setup in general.
# Reccomend upgrading AGP to the latest version (ignore all other suggestions) and change `jdk7` to `jdk8` in ./android/app/build.gradle to avoid all warnings
# JDK upgrade taken from https://stackoverflow.com/a/71186533

# Build release APK
# Choosing to split per-abi to keep size to a minimum
build-apk:
	flutter build apk --release --split-debug-info=build/app/outputs/symbols/android --split-per-abi

# Build universal release APK
# Is the full fat apk with universal support and debug info included
build-fat-apk:
	flutter build apk --release

# Build debug APK
build-debug-apk:
	flutter build apk --debug

# Build release App Bundle
build-aab:
	flutter build aab

#--------------------------------------------------------------------------------

#               _
#              | |
# __      _____| |__
# \ \ /\ / / _ \ '_ \
#  \ V  V /  __/ |_) |
#   \_/\_/ \___|_.__/
#
# Art from https://ascii.co.uk/art/web

#--------------------------------------------------------------------------------
# Flutter Web build commands


# Build web release with CanvasKit renderer

# Defaulting to canvaskit here for compatiblity and consistency with other platforms.

# Choosing to enable CSP measures for higher compatiblity and to reduce runtime codegen to improve preformance

# Disabling sourcemap genreation to reduce size of the resultant bundle

# Setting PWA strategy to offline-first to enable eager-caching and provide a hopefully better end-user experience

# Setting optimization level to O2 as that is the highest reasonably safe level for most applications
# See https://dart.dev/tools/dart-compile#js for more info

build-web:
	flutter build web --release --web-renderer=canvaskit --csp --no-source-maps --pwa-strategy=offline-first --dart2js-optimization=O2

# Build web release with HTML renderer
# All settings are otherwise identical to `build-web`
# Results in the smallest overall bundle size as the CanvasKit renderer is omitted here
build-html-web:
	flutter build web --release --web-renderer=html --csp --no-source-maps --pwa-strategy=offline-first --dart2js-optimization=O2

# Build web debug build

# Defaulting to auto here to allow easier testing of both renderers by simply switching the user-agent

# Choosing to enable CSP measures for higher compatiblity and to reduce runtime codegen to improve preformance

# Enabling sourcemap genreation to allow easier debugging

# Setting PWA strategy to none to disable caching for a better testing experience

# Setting optimization level to O0 to speed up build-times for faster debugging
# See https://dart.dev/tools/dart-compile#js for more info

build-debug-web:
	flutter build web --release --web-renderer=auto --csp --source-maps --pwa-strategy=auto --dart2js-optimization=O0

#--------------------------------------------------------------------------------

#--------------------------------------------------------------------------------
#
#               a8888b.
#              d888888b.
#              8P"YP"Y88
#              8|o||o|88
#              8'    .88
#              8`._.' Y8.
#             d/      `8b.
#            dP   .    Y8b.
#           d8:'  "  `::88b
#          d8"         'Y88b
#         :8P    '      :888
#          8a.   :     _a88P
#        ._/"Yaa_:   .| 88P|
#   jgs  \    YP"    `| 8P  `.
#   a:f  /     \.___.d|    .'
#        `--..__)8888P`._.'
#
# Art from https://ascii.co.uk/art/linux

#--------------------------------------------------------------------------------
# Linux Build Commands
#
# As mentioned earlier, all of these build instructions assume a Windows host. This remains true here.
# WSL is used for this entire section.

# Build release binary
# By default, only x64 builds are generated but here arm64 is also included for completness' sake.
# build-linux: