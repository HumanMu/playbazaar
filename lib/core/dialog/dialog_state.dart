import '../../games/entities/dialog_request_model.dart';

class DialogState {
  final List<DialogRequestModel> activeDialogs;
  final DialogRequestModel? currentRequest;
  final String? error;
  final int totalDialogsShown;

  const DialogState({
    this.activeDialogs = const [],
    this.currentRequest,
    this.error,
    this.totalDialogsShown = 0,
  });

  DialogState copyWith({
    List<DialogRequestModel>? activeDialogs,
    DialogRequestModel? currentRequest,
    String? error,
    int? totalDialogsShown,
  }) {
    return DialogState(
      activeDialogs: activeDialogs ?? this.activeDialogs,
      currentRequest: currentRequest,
      error: error,
      totalDialogsShown: totalDialogsShown ?? this.totalDialogsShown,
    );
  }

  bool get hasActiveDialogs => activeDialogs.isNotEmpty;
}
