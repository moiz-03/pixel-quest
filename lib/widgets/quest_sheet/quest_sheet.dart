import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pixelarticons/pixelarticons.dart';

import '../../services/notification_service.dart';
import '../../models/quest.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_sizes.dart';
import '../../theme/app_text_styles.dart';
import 'widgets/delete_confirm_dialog.dart';

sealed class QuestSheetResult {
  const QuestSheetResult();
}

class QuestSaved extends QuestSheetResult {
  final Quest quest;
  const QuestSaved(this.quest);
}

class QuestDeleted extends QuestSheetResult {
  const QuestDeleted();
}

class QuestSheet extends StatefulWidget {
  final Quest? existing;

  const QuestSheet({super.key, this.existing});

  bool get isEditing => existing != null;

  @override
  State<QuestSheet> createState() => _QuestSheetState();
}

class _QuestSheetState extends State<QuestSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _xpCtrl;
  late QuestCategory _category;

  bool _reminderEnabled = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 0);

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.existing?.title ?? '');
    _xpCtrl = TextEditingController(
      text: (widget.existing?.xp ?? 15).toString(),
    );
    _category = widget.existing?.category ?? QuestCategory.health;

    // Parse existing reminder
    final rt = widget.existing?.reminderTime;
    if (rt != null && rt.isNotEmpty) {
      final parts = rt.split(':');
      if (parts.length == 2) {
        final h = int.tryParse(parts[0]);
        final m = int.tryParse(parts[1]);
        if (h != null && m != null && h >= 0 && h < 24 && m >= 0 && m < 60) {
          _reminderEnabled = true;
          _reminderTime = TimeOfDay(hour: h, minute: m);
        }
      }
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _xpCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleCtrl.text.trim();
    final xp = int.parse(_xpCtrl.text.trim());
    final reminder = _reminderEnabled
        ? '${_reminderTime.hour.toString().padLeft(2, '0')}:'
              '${_reminderTime.minute.toString().padLeft(2, '0')}'
        : null;

    if (widget.isEditing) {
      // Build a NEW Quest — do not mutate widget.existing in place.
      final updated = widget.existing!.copyWith(
        title: title,
        category: _category,
        xp: xp,
        reminderTime: reminder,
        clearReminder: reminder == null,
      );
      Navigator.pop(context, QuestSaved(updated));
    } else {
      final created = Quest(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: title,
        category: _category,
        xp: xp,
        reminderTime: reminder,
      );
      Navigator.pop(context, QuestSaved(created));
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (_) => const DeleteConfirmDialog(),
    );

    if (confirmed != true || !mounted) return;
    Navigator.pop(context, const QuestDeleted());
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusXl),
        ),
        border: Border(
          top: BorderSide(color: AppColors.secondary, width: 2),
          left: BorderSide(color: AppColors.secondary, width: 2),
          right: BorderSide(color: AppColors.secondary, width: 2),
        ),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          AppSizes.xl,
          AppSizes.xl,
          AppSizes.xl,
          AppSizes.xl + bottomInset,
        ),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _header(),
              const SizedBox(height: AppSizes.lg),

              _label('Quest Title'),
              const SizedBox(height: AppSizes.sm),
              _titleField(),
              const SizedBox(height: AppSizes.lg),

              _label('Category'),
              const SizedBox(height: AppSizes.sm),
              _categoryField(),
              const SizedBox(height: AppSizes.lg),

              _label('XP Reward'),
              const SizedBox(height: AppSizes.sm),
              _xpField(),
              const SizedBox(height: AppSizes.lg),

              _label('Reminder'),
              const SizedBox(height: AppSizes.sm),
              _reminderField(),
              const SizedBox(height: AppSizes.xl),

              _submitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        Icon(
          widget.isEditing ? Pixel.edit : Pixel.note,
          color: AppColors.secondary,
          size: 24,
        ),
        const SizedBox(width: AppSizes.sm),
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              widget.isEditing ? 'EDIT QUEST' : 'ADD NEW QUEST',
              textAlign: TextAlign.center,
              maxLines: 1,
              style: AppTextStyles.h3.copyWith(letterSpacing: 1.2),
            ),
          ),
        ),
        if (widget.isEditing)
          IconButton(
            onPressed: _confirmDelete,
            tooltip: 'Delete quest',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            icon: const Icon(
              Pixel.trash,
              color: AppColors.accentDanger,
              size: 22,
            ),
          )
        else
          IconButton(
            onPressed: () => Navigator.pop(context),
            tooltip: 'Close',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            icon: const Icon(
              Pixel.close,
              color: AppColors.textPrimary,
              size: 22,
            ),
          ),
      ],
    );
  }

  Widget _label(String text) => Text(
    text,
    style: AppTextStyles.label.copyWith(color: AppColors.textPrimary),
  );

  InputDecoration _inputDecoration({String? hint, Widget? prefix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        fontFamily: AppTextStyles.pixelFont,
        fontSize: AppSizes.fontMd,
        color: AppColors.textMuted,
      ),
      prefixIcon: prefix,
      prefixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 44),
      filled: true,
      fillColor: AppColors.background,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSizes.lg,
        vertical: AppSizes.lg,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        borderSide: const BorderSide(color: AppColors.secondary, width: 1.4),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        borderSide: const BorderSide(color: AppColors.xpGreen, width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        borderSide: const BorderSide(color: AppColors.error, width: 1.4),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        borderSide: const BorderSide(color: AppColors.error, width: 1.8),
      ),
    );
  }

  Widget _titleField() {
    return TextFormField(
      controller: _titleCtrl,
      textCapitalization: TextCapitalization.sentences,
      textInputAction: TextInputAction.next,
      maxLength: 40,
      style: AppTextStyles.body.copyWith(height: 1.4),
      decoration: _inputDecoration(hint: 'e.g. Read a Book')
          .copyWith(counterText: ''),
      validator: (v) {
        final t = v?.trim() ?? '';
        if (t.isEmpty) return 'Enter a quest title';
        return null;
      },
    );
  }

  Widget _categoryField() {
    return DropdownButtonFormField<QuestCategory>(
      initialValue: _category,
      isExpanded: true,
      dropdownColor: AppColors.surfaceHigh,
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      icon: const Icon(Pixel.chevrondown, color: AppColors.secondary, size: 18),
      style: AppTextStyles.body.copyWith(height: 1.4),
      decoration: _inputDecoration(),
      items: QuestCategory.values.map((cat) {
        return DropdownMenuItem<QuestCategory>(
          value: cat,
          child: Row(
            children: [
              Icon(cat.icon, color: cat.color, size: 18),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: Text(
                  cat.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body.copyWith(height: 1.3),
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: (cat) {
        if (cat == null) return;
        setState(() => _category = cat);
      },
    );
  }

  Widget _xpField() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _xpCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submit(),
            style: AppTextStyles.body.copyWith(
              height: 1.4,
              color: AppColors.textPrimary,
            ),
            decoration: _inputDecoration(
              prefix: const Icon(
                Pixel.coin,
                color: AppColors.accentGold,
                size: 20,
              ),
            ),
            validator: (v) {
              final t = v?.trim() ?? '';
              if (t.isEmpty) return 'Required';
              final n = int.tryParse(t);
              if (n == null) return 'Numbers only';
              if (n < 5 || n > 100) return 'Between 5 and 100';
              return null;
            },
          ),
        ),
        const SizedBox(width: AppSizes.sm),
        Text(
          '(5-100)',
          style: AppTextStyles.micro.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _reminderField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Remind me daily',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Switch(
              value: _reminderEnabled,
              onChanged: (v) async {
                if (v) {
                  final granted = await NotificationService.instance
                      .requestPermission();
                  if (!granted && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Enable notifications in settings to use reminders.',
                        ),
                      ),
                    );
                    return;
                  }
                }
                setState(() => _reminderEnabled = v);
              },
              activeThumbColor: AppColors.xpGreen,
            ),
          ],
        ),
        if (_reminderEnabled) ...[
          const SizedBox(height: AppSizes.sm),
          SizedBox(
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: _reminderTime,
                  builder: (context, child) {
                    return Theme(data: Theme.of(context), child: child!);
                  },
                );
                if (picked != null && mounted) {
                  setState(() => _reminderTime = picked);
                }
              },
              icon: const Icon(Pixel.clock, size: 18),
              label: Text(_reminderTime.format(context)),
            ),
          ),
        ],
      ],
    );
  }

  Widget _submitButton() {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.xpGreen,
          foregroundColor: AppColors.textOnPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            widget.isEditing ? 'SAVE CHANGES' : 'CREATE QUEST',
            maxLines: 1,
          ),
        ),
      ),
    );
  }
}
