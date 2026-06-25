import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// A mixin or class to handle external hardware barcode scanners (HID).
/// These scanners usually act as a keyboard, typing characters rapidly and ending with 'Enter'.
class HardwareScannerListener extends StatefulWidget {
  final Widget child;
  final Function(String) onScan;

  const HardwareScannerListener({
    super.key,
    required this.child,
    required this.onScan,
  });

  @override
  State<HardwareScannerListener> createState() => _HardwareScannerListenerState();
}

class _HardwareScannerListenerState extends State<HardwareScannerListener> {
  final FocusNode _focusNode = FocusNode();
  final List<String> _buffer = [];
  DateTime? _lastKeyEventTime;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      final DateTime now = DateTime.now();
      
      // If the time between keys is too long, it's likely manual typing, not a scanner.
      // Scanners typically send keys every 10-50ms.
      if (_lastKeyEventTime != null && 
          now.difference(_lastKeyEventTime!).inMilliseconds > 100) {
        _buffer.clear();
      }
      
      _lastKeyEventTime = now;

      if (event.logicalKey == LogicalKeyboardKey.enter) {
        if (_buffer.isNotEmpty) {
          final String code = _buffer.join();
          widget.onScan(code);
          _buffer.clear();
        }
      } else {
        final String char = event.character ?? '';
        if (char.isNotEmpty) {
          _buffer.add(char);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: widget.child,
    );
  }
}
