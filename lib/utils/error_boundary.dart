import 'package:flutter/material.dart';

/// A widget that catches and handles errors in its widget subtree.
/// 
/// When an error occurs in the widget tree below this widget, it will display
/// the provided [fallback] widget instead of crashing the app.
class ErrorBoundary extends StatefulWidget {
  /// The widget below this widget in the tree.
  final Widget child;

  /// A builder that creates a widget to display when an error occurs.
  final Widget Function(Object error, StackTrace? stackTrace) fallback;

  /// Creates an error boundary.
  const ErrorBoundary({
    super.key,
    required this.child,
    required this.fallback,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;
  StackTrace? _stackTrace;

  @override
  void didCatchError(Object error, StackTrace stackTrace) {
    debugPrint('ErrorBoundary caught error: $error');
    debugPrintStack(stackTrace: stackTrace);
    
    setState(() {
      _error = error;
      _stackTrace = stackTrace;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.fallback(_error!, _stackTrace);
    }
    return widget.child;
  }
}