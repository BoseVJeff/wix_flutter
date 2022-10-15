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
	{rm -r .\buildbak\}
	{rm -r .\symbolsbak\}

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

# Clean Linux platform files
clean-linux:
	rm -r .\linux\

# Regenerate Android platform files
regen-android: clean-android
	flutter create . --platforms=android

# Regenerate Windows platform files
regen-windows: clean-windows
	flutter create . --platforms=windows

# Regenerate Web files
regen-web: clean-web
	flutter create . --platforms=web

# Regenrate Linux platform files
regen-linux: clean-linux
	flutter create . --platforms=linux

# Regenerate all platform files
regen-all-platforms: clean-android clean-windows clean-web
	flutter create . --platforms=android,windows,web,linux

# Clean and rebuild Dart codegen (json_serializable, freezed, etc using build_runner)
regen-dart:
	flutter pub run build_runner build --delete-conflicting-outputs

# Clean and regenerate all generated files in the project
regen-all: regen-all-platforms rebuild regen-dart

#--------------------------------------------------------------------------------
#
# .=====================================================.
# ||                                                   ||
# ||   _       _--""--_                                ||
# ||     " --""   |    |   .--.           |    ||      ||
# ||   " . _|     |    |  |    |          |    ||      ||
# ||   _    |  _--""--_|  |----| |.-  .-i |.-. ||      ||
# ||     " --""   |    |  |    | |   |  | |  |         ||
# ||   " . _|     |    |  |    | |    `-( |  | ()      ||
# ||   _    |  _--""--_|             |  |              ||
# ||     " --""                      `--'              ||
# ||                                                   || rg / mfj
# `=====================================================`
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
	flutter build windows --release --split-debug-info=build/symbols/windows

# Build the debug version of the app project (.sln) file from the Flutter CLI
build-sln-debug-exe:
	flutter build windows --debug

# Build the executable of the release version of the app
# Not using `import-vs-2022` here as context/imports are lost inbetween steps
build-vs-exe:
	Import-Module '{{VsDevShellDllPath}}' && Enter-VsDevShell 05870f35 -SkipAutomaticLocation &&  msbuild ./build/windows/wix_flutter.sln -property:Configuration=Release -property:Platform=x64

# Build the executable of the debug version of the app
# Not using `import-vs-2022` here as context/imports are lost inbetween steps
build-vs-debug-exe:
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
	flutter build apk --release --split-debug-info=build/symbols/android --split-per-abi

# Build universal release APK
# Is the full fat apk with universal support and debug info included
build-fat-apk:
	flutter build apk --release

# Build debug APK
build-debug-apk:
	flutter build apk --debug

# Build release App Bundle
build-aab:
	flutter build appbundle

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

# Attempt to build a bundle which only makes first-party requests i.e. no external requests.
# Canvaskit used here is the local variant that is generated but not used by default (for some reason).
# (Canvaskit URL strategy inspired by https://github.com/flutter/engine/pull/19822)
# However, this does not prevent a font request to https://fonts.gstatic.com/s/roboto/v20/KFOmCnqEu92Fr1Me5WZLCzYlKw.ttf .
# To avoid this, download a local copy of the font (defalut is Roboto-Regular) and add it to the fonts list in pubspec.yaml .
# e.g. If the font is stored in `google_fonts` as `Roboto-Regular.ttf`, add this to the flutter section of the pubspec
#   fonts:
#     - family: Roboto
#       fonts:
#         - asset: google_fonts/Roboto-Regular.ttf
# (Local font tip taken from https://github.com/flutter/flutter/issues/77580#issuecomment-1112333700)
build-fp-web base-href='/':
	flutter build web --release --base-href={{base-href}} --web-renderer=canvaskit --csp --no-source-maps --pwa-strategy=offline-first --dart2js-optimization=O2 --dart-define=FLUTTER_WEB_CANVASKIT_URL={{base-href}}canvaskit/

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
	flutter build web --release --web-renderer=auto --csp --source-maps --pwa-strategy=none --dart2js-optimization=O0

build-gh-pages:
	just build-fp-web '/wix_flutter/'
	if(Test-Path .\docs\) {rm -r .\docs\}
	Copy-Item ./build/web -Destination .\docs -Filter * -Recurse

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
# Docker is used for this entire section.
# Assuming a Windows host leads to the following complications:
# 1. All Flutter libraries are in their Windows variants. To get the Linux variants, `flutter clean && flutter pub get` needs to be run from inside the container itself. The `flutter clean` part results in all existing builds to be lost, so care must be taken to back them up if needed. Use the `build-all` recipie that takes care of these concerns if that is appropriate. Use it as a guidance if custom behaviour is needed.
# 2. Having to run `flutter clean` at the start of each run results in lost builds. This makes it impossible for the Debug and Release builds of Linux to coexist. If for some reason that is desired, use the `build-both-linux` recipie instead.

# Test if Docker is installed and running
# Throws a halting error if Docker is not running
test-docker:
	try {docker --version} catch {error("Docker not found. Try installing Docker and try again.")}
	docker ps
	if($? -eq $false) { error("Error connecting to Docker daemon. Try reconnecting/restarting Docker") }

# Build release binary
# By default, only x64 builds are generated but here arm64 is also included for completness' sake.
build-linux: test-docker
	./build.ps1

# Build debug binary
build-debug-linux: test-docker
	./build-debug.ps1

# Build debug and release togteher
build-both-linux: test-docker
	./build-debug-and-release.ps1

#--------------------------------------------------------------------------------
#
#   ooooooooooooooooooooooooooooooooooooo
#   8                                .d88
#   8  oooooooooooooooooooooooooooood8888
#   8  8888888888888888888888888P"   8888    oooooooooooooooo
#   8  8888888888888888888888P"      8888    8              8
#   8  8888888888888888888P"         8888    8             d8
#   8  8888888888888888P"            8888    8            d88
#   8  8888888888888P"               8888    8           d888
#   8  8888888888P"                  8888    8          d8888
#   8  8888888P"                     8888    8         d88888
#   8  8888P"                        8888    8        d888888
#   8  8888oooooooooooooooooooooocgmm8888    8       d8888888
#   8 .od88888888888888888888888888888888    8      d88888888
#   8888888888888888888888888888888888888    8     d888888888
#                                            8    d8888888888
#      ooooooooooooooooooooooooooooooo       8   d88888888888
#     d                       ...oood8b      8  d888888888888
#    d              ...oood888888888888b     8 d8888888888888
#   d     ...oood88888888888888888888888b    8d88888888888888
#  dood8888888888888888888888888888888888b
#
# All Builds together

# Generate all release builds
# Naming this as such to avoid accidently generating debug builds when not needed.
build-all: build-linux
	if(Test-Path .\buildbak\) {rm -r .\buildbak\}
	if(Test-Path .\symbolsbak\) {rm -r .\symbolsbak\}
	Copy-Item .\build\linux\ -Filter * -Destination ./buildbak -Recurse
	Copy-Item .\build\symbols\linux -Filter * -Destination ./symbolsbak -Recurse
	just rebuild
	just build-apk
	just build-exe
	just build-web
	Copy-Item .\buildbak\ -Filter * -Destination .\build\linux\ -Recurse
	Copy-Item .\symbolsbak\ -Filter * -Destination .\build\symbols\linux\ -Recurse
	{rm -r .\buildbak\}
	{rm -r .\symbolsbak\}

# Generate all builds possible
# This will generate over 9000(!) files...
# Web rewrites the same folder for all variants. TODO: Copy individual builds to debug, release folders
# The individual `rm` at the end are covered in barces to avoid accidental concats of the two commands that seems to occour for some reason.
build-all-variants: build-both-linux
	if(Test-Path .\buildbak\) {rm -r .\buildbak\}
	if(Test-Path .\symbolsbak\) {rm -r .\symbolsbak\}
	Copy-Item .\build\linux\ -Filter * -Destination ./buildbak -Recurse
	Copy-Item .\build\symbols\linux -Filter * -Destination ./symbolsbak -Recurse
	just rebuild
	just build-apk
	just build-fat-apk
	just build-aab
	just build-exe
	just build-debug-exe
	just build-web
	Copy-Item .\build\web\ -Filter * -Destination .\build\web_release -Recurse
	just build-html-web
	Copy-Item .\build\web\ -Filter * -Destination .\build\web_release_html -Recurse
	just build-debug-web
	Copy-Item .\build\web\ -Filter * -Destination .\build\web_debug -Recurse
	Copy-Item .\buildbak\ -Filter * -Destination .\build\linux\ -Recurse
	Copy-Item .\symbolsbak\ -Filter * -Destination .\build\symbols\linux\ -Recurse
	{rm -r .\buildbak\}
	{rm -r .\symbolsbak\}

# Benchmark
benchmark:
	Measure-Command {just regen-all && just build-all-variants | Out-Default}