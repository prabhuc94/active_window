# active_window

Plugin to detect active window

## Usage

A simple usage example:

```dart
import 'package:active_window/auto_active_window.dart';

main() {
  final windowInfo = await ActiveWindow().getActiveWindow();

  // or with observer
  final windowObserver = AutoActiveWindowInfo()
      ..windowStream.listen((event) {
        print(event);
      });
    windowObserver.startService();
}
```

## Install
`flutter pub add active_window`
