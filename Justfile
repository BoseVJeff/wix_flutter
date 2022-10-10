# use PowerShell Core instead of sh:
set shell := ["pwsh.exe", "-c"]

clean:
	flutter clean

rebuild: clean
	flutter pub get

import-vs-2022:
	&{Import-Module 'C:/Program Files/Microsoft Visual Studio/2022/Community/Common7/Tools/Microsoft.VisualStudio.DevShell.dll'; Enter-VsDevShell 05870f35}

build-sln-exe:
	flutter build windows --release --split-debug-info=build/app/outputs/symbols/windows

build-vs-exe: import-vs-2022
	msbuild ./build/windows/wix_flutter.sln

build-exe: build-sln-exe build-vs-exe