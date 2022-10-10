# use PowerShell Core instead of sh:
set shell := ["pwsh.exe", "-c"]

#--------------------------------------------------------------------------------
# General Flutter Tools

# Use to clean and delete most generated code and files
clean:
	flutter clean

# Clean and regenerate code and files
rebuild: clean
	flutter pub get

#--------------------------------------------------------------------------------

#--------------------------------------------------------------------------------
# Windows build commands
# These are assumend to run on a Windows platform

# Use this to import VS 2022 into the context. Exposes msbuild, etc to allow VS project automation
# Update this for different versions of Visual Studio
import-vs-2022:
	&{Import-Module 'C:/Program Files/Microsoft Visual Studio/2022/Community/Common7/Tools/Microsoft.VisualStudio.DevShell.dll'; Enter-VsDevShell 05870f35}

# Build the release version of the app project (.sln) file from the Flutter CLI
build-sln-exe:
	flutter build windows --release --split-debug-info=build/app/outputs/symbols/windows

# Build the debug version of the app project (.sln) file from the Flutter CLI
build-sln-debug-exe:
	flutter build windows --debug

# Build the executable of the release version of the app
build-vs-exe: import-vs-2022
	msbuild ./build/windows/wix_flutter.sln -property:Configuration=Release -property:Platform=x64

# Build the executable of the debug version of the app
build-vs-debug-exe: import-vs-2022
	msbuild ./build/windows/wix_flutter.sln -property:Configuration=Debug -property:Platform=x64

# Build .exe for release
build-exe: build-sln-exe build-vs-exe

# Build .exe for debug
build-debug-exe: build-sln-debug-exe build-vs-debug-exe

#--------------------------------------------------------------------------------

#--------------------------------------------------------------------------------
# Android build commands

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

#--------------------------------------------------------------------------------
# Flutter Web build commands


# Build web release

# Defaulting to canvaskit here for compatiblity and consistency with other platforms.

# Choosing to enable CSP measures for higher compatiblity and to reduce runtime codegen to improve preformance

# Disabling sourcemap genreation to reduce size of the resultant bundle

# Setting PWA strategy to offline-first to enable eager-caching and provide a hopefully better end-user experience

# Setting optimization level to O2 as that is the highest reasonably safe level for most applications
# See https://dart.dev/tools/dart-compile#js for more info

build-web:
	flutter build web --release --web-renderer=canvaskit --csp --no-source-maps --pwa-strategy=offline-first --dart2js-optimization=O2

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