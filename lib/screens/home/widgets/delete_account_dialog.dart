import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_sizes.dart';
import '../../../theme/app_text_styles.dart';

class DeleteAccountDialog extends StatefulWidget {
  /// Called with the user-entered password when they tap Delete.
  /// Should throw on failure.
  final Future<void> Function(String password) onConfirm;

  const DeleteAccountDialog({super.key, required this.onConfirm});

  static Future<bool?> show(
    BuildContext context, {
    required Future<void> Function(String password) onConfirm,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => DeleteAccountDialog(onConfirm: onConfirm),
    );
  }

  @override
  State<DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<DeleteAccountDialog> {
  final _passCtrl = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    final password = _passCtrl.text;
    if (password.isEmpty) {
      setState(() => _error = 'Enter your password.');
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      await widget.onConfirm(password);
      if (!mounted) return;
      Navigator.pop(context, true);
    } on Exception catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = _messageFor(e);
      });
    }
  }

  String _messageFor(Object e) {
    final code = _authCode(e);
    switch (code) {
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect password.';
      case 'requires-recent-login':
        return 'Please log out and log back in, then try again.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      default:
        return 'Could not delete account. Try again.';
    }
  }

  /// Extracts the Firebase error code from any exception without
  /// importing firebase_auth into this file.
  String? _authCode(Object e) {
    try {
      final dyn = e as dynamic;
      return dyn.code as String?;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete account?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'This will permanently delete your account, quests, XP, '
            'streak history, and username. This cannot be undone.',
          ),
          const SizedBox(height: AppSizes.md),
          TextField(
            controller: _passCtrl,
            obscureText: true,
            enabled: !_busy,
            decoration: const InputDecoration(
              labelText: 'Password',
              hintText: 'Confirm with your password',
            ),
            onSubmitted: (_) => _confirm(),
          ),
          if (_error != null) ...[
            const SizedBox(height: AppSizes.sm),
            Text(
              _error!,
              style: AppTextStyles.caption.copyWith(color: AppColors.error),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _busy ? null : _confirm,
          child: _busy
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text(
                  'Delete',
                  style: TextStyle(color: AppColors.accentDanger),
                ),
        ),
      ],
    );
  }
}
