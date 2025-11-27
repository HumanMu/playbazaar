
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../games/entities/dialog_request_model.dart';
import 'dialog_manager.dart';
import 'dialog_state.dart';

/// Riverpod provider for DialogManager
final dialogManagerProvider =
StateNotifierProvider<DialogManager, DialogState>((ref) {
  final manager = DialogManager();

  // Optional: Setup global callbacks
  manager.onDialogShown = (id) {
    debugPrint('✅ Dialog shown: $id');
  };

  manager.onDialogClosed = (id, result) {
    debugPrint('❌ Dialog closed: $id with result: $result');
  };

  manager.onDialogError = (id, error) {
    debugPrint('⚠️ Dialog error: $id - $error');
  };

  return manager;
});


/// Dialog Listener Widget with enhanced error handling
class DialogListener extends ConsumerStatefulWidget {
  final Widget child;
  final bool useRootNavigator;
  final Duration debounceDelay;

  const DialogListener({
    super.key,
    required this.child,
    this.useRootNavigator = true,
    this.debounceDelay = Duration.zero,
  });

  @override
  ConsumerState<DialogListener> createState() => _DialogListenerState();
}

class _DialogListenerState extends ConsumerState<DialogListener>
    with WidgetsBindingObserver {
  final Map<String, bool> _shownDialogs = {};
  final Set<String> _processingDialogs = {};
  Timer? _debounceTimer;
  bool _isAppInForeground = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _isAppInForeground = state == AppLifecycleState.resumed;

    // Close all dialogs when app goes to background (optional)
    if (state == AppLifecycleState.paused) {
      debugPrint('🔄 App paused, dialogs remain open');
      // Uncomment to close dialogs on background:
      //ref.read(dialogManagerProvider.notifier).closeAllDialogs();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<DialogState>(
      dialogManagerProvider,
          (previous, next) {
        // Debounce rapid state changes
        _debounceTimer?.cancel();
        _debounceTimer = Timer(widget.debounceDelay, () {
          if (!mounted) return;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            _handleDialogStateChange(previous, next);
          });
        });
      },
    );

    return widget.child;
  }

  void _handleDialogStateChange(DialogState? previous, DialogState next) {
    // Only process if app is in foreground
    if (!_isAppInForeground) {
      debugPrint('⏸️ App in background, skipping dialog operations');
      return;
    }

    // Handle new dialog request
    if (next.currentRequest != null &&
        !_shownDialogs.containsKey(next.currentRequest!.id) &&
        !_processingDialogs.contains(next.currentRequest!.id)) {
      _processingDialogs.add(next.currentRequest!.id);

      try {
        _showDialog(next.currentRequest!);
      } catch (e) {
        debugPrint('❌ Error showing dialog: $e');
        ref.read(dialogManagerProvider.notifier)
            .closeDialogById(next.currentRequest!.id);
      } finally {
        _processingDialogs.remove(next.currentRequest!.id);
      }
    }

    // Handle dialog closure
    if (previous != null && previous.activeDialogs.isNotEmpty) {
      for (final prevDialog in previous.activeDialogs) {
        if (!next.activeDialogs.any((d) => d.id == prevDialog.id)) {
          _closeDialog(prevDialog.id);
        }
      }
    }
  }

  void _showDialog(DialogRequestModel request) {
    if (!mounted) return;

    // Double-check dialog isn't already showing
    if (_shownDialogs.containsKey(request.id)) {
      debugPrint('⚠️ Dialog ${request.id} already showing');
      return;
    }

    _shownDialogs[request.id] = true;

    try {
      showDialog<dynamic>(
        context: context,
        barrierDismissible: request.barrierDismissible,
        barrierColor: request.barrierColor,
        useSafeArea: request.useSafeArea,
        routeSettings: request.routeSettings,
        builder: (BuildContext dialogContext) => PopScope(
          canPop: request.barrierDismissible,
          onPopInvokedWithResult: (bool didPop, dynamic result) {
            if (didPop) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted && _shownDialogs.containsKey(request.id)) {
                  ref.read(dialogManagerProvider.notifier)
                      .closeDialogById(request.id, result);
                }
              });
            }
          },
          child: request.dialog,
        ),
      ).then((result) {
        // Dialog dismissed by Flutter
        if (mounted && _shownDialogs.containsKey(request.id)) {
          ref.read(dialogManagerProvider.notifier)
              .closeDialogById(request.id, result);
        }
      }).catchError((error) {
        debugPrint('❌ Error in dialog ${request.id}: $error');
        _shownDialogs.remove(request.id);
        ref.read(dialogManagerProvider.notifier)
            .closeDialogById(request.id);
      });
    } catch (e) {
      debugPrint('❌ Failed to show dialog ${request.id}: $e');
      _shownDialogs.remove(request.id);
      ref.read(dialogManagerProvider.notifier).closeDialogById(request.id);
    }
  }

  void _closeDialog(String dialogId) {
    if (!mounted) return;

    if (_shownDialogs.containsKey(dialogId)) {
      try {
        if (Navigator.canPop(context)) {
          Navigator.of(context, rootNavigator: widget.useRootNavigator).pop();
        } else {
          debugPrint('⚠️ Cannot pop dialog $dialogId - no route to pop');
        }
      } catch (e) {
        debugPrint('❌ Error closing dialog $dialogId: $e');
      } finally {
        _shownDialogs.remove(dialogId);
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _debounceTimer?.cancel();
    _shownDialogs.clear();
    _processingDialogs.clear();
    super.dispose();
  }
}
