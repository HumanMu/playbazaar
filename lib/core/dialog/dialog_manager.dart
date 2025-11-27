import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../games/entities/dialog_request_model.dart';
import 'dialog_state.dart';

/// Enum for dialog priority levels
enum DialogPriority {
  low,
  normal,
  high,
  critical,
}

/// Extended dialog request with priority support
class PriorityDialogRequest extends DialogRequestModel {
  final DialogPriority priority;
  final bool canBeInterrupted;
  final Duration? customTimeout;

  PriorityDialogRequest({
    required super.dialog,
    super.barrierDismissible,
    super.barrierColor,
    super.useSafeArea,
    super.routeSettings,
    this.priority = DialogPriority.normal,
    this.canBeInterrupted = true,
    this.customTimeout,
  });
}


/// Callback types for dialog lifecycle events
typedef DialogShownCallback = void Function(String dialogId);
typedef DialogClosedCallback = void Function(String dialogId, dynamic result);
typedef DialogErrorCallback = void Function(String dialogId, Object error);

class DialogManager extends StateNotifier<DialogState> {
  DialogManager() : super(const DialogState());

  final Map<String, Completer<dynamic>> _completers = {};
  final Map<String, DateTime> _dialogShowTimes = {};

  // Lifecycle callbacks
  DialogShownCallback? onDialogShown;
  DialogClosedCallback? onDialogClosed;
  DialogErrorCallback? onDialogError;

  static const int _maxConcurrentDialogs = 3;
  static const int _maxQueuedDialogs = 10;
  static const Duration _defaultTimeout = Duration(minutes: 5);
  static const Duration _criticalTimeout = Duration(minutes: 15);

  /// Show a dialog with priority support and lifecycle management
  Future<T?> showDialog<T>({
    required Widget dialog,
    bool barrierDismissible = true,
    Color? barrierColor,
    bool useSafeArea = true,
    RouteSettings? routeSettings,
    Duration? timeout,
    DialogPriority priority = DialogPriority.normal,
    bool canBeInterrupted = true,
  }) async {
    // Validate queue size to prevent memory issues
    if (state.activeDialogs.length >= _maxQueuedDialogs) {
      debugPrint('⚠️ DialogManager: Queue full ($_maxQueuedDialogs), rejecting dialog');
      onDialogError?.call('queue_full', Exception('Dialog queue is full'));
      return null;
    }

    final request = PriorityDialogRequest(
      dialog: dialog,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      useSafeArea: useSafeArea,
      routeSettings: routeSettings,
      priority: priority,
      canBeInterrupted: canBeInterrupted,
      customTimeout: timeout,
    );

    // Handle critical priority - close interruptible dialogs
    if (priority == DialogPriority.critical) {
      _handleCriticalDialog();
    }

    final completer = Completer<T?>();
    _completers[request.id] = completer;
    _dialogShowTimes[request.id] = DateTime.now();

    // Sort dialogs by priority
    final updatedDialogs = [...state.activeDialogs, request]
      ..sort((a, b) {
        if (a is PriorityDialogRequest && b is PriorityDialogRequest) {
          return b.priority.index.compareTo(a.priority.index);
        }
        return 0;
      });

    state = state.copyWith(
      activeDialogs: updatedDialogs,
      currentRequest: updatedDialogs.first,
      totalDialogsShown: state.totalDialogsShown + 1,
    );

    // Notify listeners
    onDialogShown?.call(request.id);

    // Setup timeout
    final effectiveTimeout = timeout ??
        (priority == DialogPriority.critical ? _criticalTimeout : _defaultTimeout);

    _setupTimeout(request.id, effectiveTimeout);

    try {
      final result = await completer.future;
      _logDialogMetrics(request.id);
      return result;
    } on TimeoutException {
      debugPrint('⏱️ DialogManager: Dialog ${request.id} timed out');
      onDialogError?.call(request.id, TimeoutException('Dialog timed out'));
      return null;
    } catch (e) {
      debugPrint('❌ DialogManager: Error in dialog ${request.id}: $e');
      onDialogError?.call(request.id, e);
      return null;
    }
  }

  /// Handle critical priority dialogs
  void _handleCriticalDialog() {
    final interruptible = state.activeDialogs
        .whereType<PriorityDialogRequest>()
        .where((d) => d.canBeInterrupted)
        .toList();

    for (final dialog in interruptible) {
      closeDialogById(dialog.id, null);
    }
  }

  /// Setup auto-cleanup timeout
  void _setupTimeout(String dialogId, Duration timeout) {
    Future.delayed(timeout, () {
      if (_completers.containsKey(dialogId)) {
        debugPrint('⏱️ DialogManager: Auto-closing dialog $dialogId after timeout');
        closeDialogById(dialogId, null);
      }
    });
  }

  /// Log dialog performance metrics
  void _logDialogMetrics(String dialogId) {
    final showTime = _dialogShowTimes.remove(dialogId);
    if (showTime != null) {
      final duration = DateTime.now().difference(showTime);
      debugPrint('📊 DialogManager: Dialog $dialogId was shown for ${duration.inSeconds}s');
    }
  }

  /// Get dialog by route name
  DialogRequestModel? getDialogByRouteName(String routeName) {
    try {
      return state.activeDialogs.firstWhere(
            (d) => d.routeSettings?.name == routeName,
      );
    } catch (_) {
      return null;
    }
  }

  /// Check if a dialog with specific route name is showing
  bool isDialogShowingByRouteName(String routeName) {
    return state.activeDialogs.any(
          (d) => d.routeSettings?.name == routeName,
    );
  }

  /// Close dialog by route name
  void closeDialogByRouteName(String routeName) {
    final dialog = getDialogByRouteName(routeName);
    if (dialog != null) {
      closeDialogById(dialog.id);
    }
  }

  /// Close the topmost dialog
  void closeDialog([dynamic result]) {
    if (state.activeDialogs.isEmpty) return;

    final current = state.activeDialogs.first;
    _completeDialog(current.id, result);

    final updatedDialogs = List<DialogRequestModel>.from(state.activeDialogs)
      ..remove(current);

    state = state.copyWith(
      activeDialogs: updatedDialogs,
      currentRequest: updatedDialogs.isNotEmpty ? updatedDialogs.first : null,
    );

    onDialogClosed?.call(current.id, result);
  }

  /// Close a specific dialog by ID
  void closeDialogById(String dialogId, [dynamic result]) {
    final dialog = state.activeDialogs.cast<DialogRequestModel?>().firstWhere(
          (d) => d?.id == dialogId,
      orElse: () => null,
    );

    if (dialog == null) return;

    _completeDialog(dialogId, result);

    final updatedDialogs = List<DialogRequestModel>.from(state.activeDialogs)
      ..removeWhere((d) => d.id == dialogId);

    state = state.copyWith(
      activeDialogs: updatedDialogs,
      currentRequest: updatedDialogs.isNotEmpty ? updatedDialogs.first : null,
    );

    onDialogClosed?.call(dialogId, result);
  }

  /// Close all dialogs
  void closeAllDialogs() {
    for (final dialog in state.activeDialogs) {
      _completeDialog(dialog.id, null);
      onDialogClosed?.call(dialog.id, null);
    }

    _dialogShowTimes.clear();
    state = const DialogState();
  }

  /// Close all dialogs of a specific priority
  void closeDialogsByPriority(DialogPriority priority) {
    final dialogsToClose = state.activeDialogs
        .whereType<PriorityDialogRequest>()
        .where((d) => d.priority == priority)
        .toList();

    for (final dialog in dialogsToClose) {
      closeDialogById(dialog.id, null);
    }
  }

  /// Safely complete a dialog's completer
  void _completeDialog(String dialogId, dynamic result) {
    final completer = _completers.remove(dialogId);
    if (completer != null && !completer.isCompleted) {
      try {
        completer.complete(result);
      } catch (e) {
        debugPrint('❌ DialogManager: Error completing dialog $dialogId: $e');
      }
    }
    _dialogShowTimes.remove(dialogId);
  }

  /// Check if a specific dialog is showing
  bool isDialogShowing(String dialogId) {
    return state.activeDialogs.any((d) => d.id == dialogId);
  }

  /// Get dialog by ID
  DialogRequestModel? getDialogById(String dialogId) {
    try {
      return state.activeDialogs.firstWhere((d) => d.id == dialogId);
    } catch (_) {
      return null;
    }
  }

  /// Get all dialogs by priority
  List<DialogRequestModel> getDialogsByPriority(DialogPriority priority) {
    return state.activeDialogs
        .whereType<PriorityDialogRequest>()
        .where((d) => d.priority == priority)
        .toList();
  }

  /// Get count of active dialogs
  int get activeDialogCount => state.activeDialogs.length;

  /// Get total dialogs shown in session
  int get totalDialogsShown => state.totalDialogsShown;

  /// Check if can show more dialogs
  bool get canShowDialog => state.activeDialogs.length < _maxConcurrentDialogs;

  @override
  void dispose() {
    // Clean up all resources
    for (final completer in _completers.values) {
      if (!completer.isCompleted) {
        completer.complete(null);
      }
    }
    _completers.clear();
    _dialogShowTimes.clear();
    super.dispose();
  }
}

