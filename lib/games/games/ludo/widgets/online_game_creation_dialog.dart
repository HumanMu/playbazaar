import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/utils.dart';
import '../../../../global_widgets/rarely_used/text_2_copy.dart';

class OnlineGameOptionsDialog extends StatefulWidget {
  final Function(String gameCode) onJoinGame;
  final VoidCallback onCreateGame;
  final VoidCallback? onCancel;
  final String? title;
  final String? joinButtonText;
  final String? createButtonText;
  final String? codeHint;
  final String? gameCode;


  const OnlineGameOptionsDialog({
    super.key,
    required this.onJoinGame,
    required this.onCreateGame,
    this.onCancel,
    this.title = 'Play Online',
    this.joinButtonText = 'Join Game',
    this.createButtonText = 'Create New Game',
    this.codeHint = 'Enter game code',
    this.gameCode
  });

  @override
  State<OnlineGameOptionsDialog> createState() => _OnlineGameOptionsDialogState();
}

class _OnlineGameOptionsDialogState extends State<OnlineGameOptionsDialog> {
  final TextEditingController _codeController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isJoinMode = true;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }


  // In _OnlineGameOptionsPopupState
  void _handleJoinGame() {
    if (_formKey.currentState!.validate()) {
      final code = _codeController.text.trim().toUpperCase();
      widget.onJoinGame(code);
    }
  }

  void _handleCreateGame() {
    widget.onCreateGame();
  }

  String? _validateGameCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'enter_game_code'.tr;
    }
    if (value.trim().length <= 5 || 7 <= value.trim().length) {
      String template = 'exact_code_limit'.tr;
      String message = template.replaceAll('%1', 6.toString());
      return message;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 8,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildToggleButtons(),
            const SizedBox(height: 24),
            _buildContent(),
            const SizedBox(height: 24),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(
          Icons.wifi,
          color: Colors.green,
          size: 28,
        ),
        const SizedBox(width: 12),
        Expanded( // Wrap Text with Expanded
          child: Text(
            widget.title!,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  Widget _buildToggleButtons() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildToggleButton(
              text: 'join_with_code'.tr,
              icon: Icons.login,
              isSelected: _isJoinMode,
              onTap: () => setState(() => _isJoinMode = true),
            ),
          ),
          Expanded(
            child: _buildToggleButton(
              text: 'btn_new_game'.tr,
              icon: Icons.add_circle,
              isSelected: !_isJoinMode,
              onTap: () => setState(() => _isJoinMode = false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required String text,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.green
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? Colors.white
                  : Theme.of(context).textTheme.bodyMedium?.color,
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? Colors.white
                    : Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _isJoinMode ? _buildJoinContent() : _buildCreateContent(),
    );
  }

  Widget _buildJoinContent() {
    return Form(
      key: _formKey,
      child: Column(
        key: const ValueKey('join'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'enter_game_code'.tr,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _codeController,
            validator: _validateGameCode,
            textCapitalization: TextCapitalization.characters,
            inputFormatters: [
              UpperCaseTextFormatter(),
              LengthLimitingTextInputFormatter(10),
            ],
            decoration: InputDecoration(
              hintText: widget.codeHint,
              prefixIcon: const Icon(Icons.vpn_key),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
            ),
            onFieldSubmitted: (_) => _handleJoinGame(),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateContent() {
    return Column(
      key: ValueKey('btn_start'.tr),
      children: [
        const SizedBox(height: 16),
        Text(
          'create_and_invite'.tr,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'you_will_receive_code'.tr,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
          ),
        ),
        Text2Copy(
          inputText: widget.gameCode??"",
          bgColor: Colors.white70,
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => widget.onCancel?.call(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              side: const BorderSide(color: Colors.red)
            ),
            child: Text('btn_cancel'.tr, style: TextStyle(color: Colors.red),),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: _isJoinMode ? _handleJoinGame : _handleCreateGame,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              side: const BorderSide(color: Colors.green),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isJoinMode ? Icons.login : Icons.add_circle,
                  size: 20,
                  color: Colors.green,
                ),
                const SizedBox(width: 8),
                Text(_isJoinMode ? widget.joinButtonText! : widget.createButtonText!,
                  style: TextStyle(color: Colors.green),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Custom text formatter to convert input to uppercase
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
