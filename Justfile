# use PowerShell Core instead of sh:
set shell := ["pwsh.exe", "-c"]

build-exe:
	flutter build windows --release --split-debug-info=build/app/outputs/symbols/windows