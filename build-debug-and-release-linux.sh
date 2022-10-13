cd app
flutter clean && flutter pub get
# Builds only x64 by default, explicitly mentioning that as cross-compilation is not supported
# Quote: Cross-build from Linux x64 host to Linux arm64 target is not currently supported.
flutter build linux --debug
flutter build linux --release --split-debug-info=build/symbols/linux --target-platform=linux-x64
# flutter build linux --release --split-debug-info=build/symbols/linux --target-platform=linux-arm64