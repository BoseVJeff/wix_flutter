cd app
flutter clean && flutter pub get
flutter build linux --release --split-debug-info=build/symbols/linux