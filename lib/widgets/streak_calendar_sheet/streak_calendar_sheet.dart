import 'package:flutter/material.dart';
import 'package:pixelarticons/pixelarticons.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_sizes.dart';
import '../../theme/app_text_styles.dart';
import 'widgets/streak_handle_bar.dart';
import 'widgets/streak_header.dart';
import 'widgets/streak_legend.dart';
import 'widgets/weekday_row.dart';

class StreakCalendarSheet extends StatefulWidget {
  /// ISO dates ("2026-10-06") on which the user completed at least one quest.
  final Set<String> history;

  /// The user's current consecutive-day streak.
  final int currentStreak;

  const StreakCalendarSheet({
    super.key,
    required this.history,
    required this.currentStreak,
  });

  static Future<void> show(
    BuildContext context, {
    required Set<String> history,
    required int currentStreak,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          StreakCalendarSheet(history: history, currentStreak: currentStreak),
    );
  }

  @override
  State<StreakCalendarSheet> createState() => _StreakCalendarSheetState();
}

class _StreakCalendarSheetState extends State<StreakCalendarSheet> {
  late DateTime _visibleMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _visibleMonth = DateTime(now.year, now.month, 1);
  }

  // ── Date helpers ─────────────────────────────────────────────────────────
  String _iso(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  bool _isToday(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  bool _isFuture(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return d.isAfter(today);
  }

  /// Earliest date the user has ever been active. Used as the "start line"
  /// for the calendar — days before this are shown as neutral.
  DateTime? get _firstActive {
    if (widget.history.isEmpty) return null;
    final sorted = widget.history.toList()..sort();
    return DateTime.tryParse(sorted.first);
  }

  // ── Month navigation ─────────────────────────────────────────────────────
  bool get _canGoForward {
    final now = DateTime.now();
    final next = DateTime(_visibleMonth.year, _visibleMonth.month + 1, 1);
    return !next.isAfter(DateTime(now.year, now.month, 1));
  }

  void _prevMonth() {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    if (!_canGoForward) return;
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1, 1);
    });
  }

  String _monthName(int m) => const [
    'JANUARY',
    'FEBRUARY',
    'MARCH',
    'APRIL',
    'MAY',
    'JUNE',
    'JULY',
    'AUGUST',
    'SEPTEMBER',
    'OCTOBER',
    'NOVEMBER',
    'DECEMBER',
  ][m - 1];

  // ── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.9;

    return RepaintBoundary(
      child: Container(
        constraints: BoxConstraints(maxHeight: maxHeight),
        decoration: const BoxDecoration(
          color: AppColors.surfaceHigh,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSizes.radiusXl),
          ),
          border: Border(
            top: BorderSide(color: AppColors.xpGreen, width: 2),
            left: BorderSide(color: AppColors.xpGreen, width: 2),
            right: BorderSide(color: AppColors.xpGreen, width: 2),
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSizes.lg,
            AppSizes.md,
            AppSizes.lg,
            AppSizes.xxl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const StreakHandleBar(),
              const SizedBox(height: AppSizes.lg),
              const StreakHeader(),
              const SizedBox(height: AppSizes.lg),
              _monthNavigator(),
              const SizedBox(height: AppSizes.md),
              const WeekdayRow(),
              const SizedBox(height: AppSizes.xs),
              _calendarGrid(),
              const SizedBox(height: AppSizes.lg),
              StreakLegend(
                currentStreak: widget.currentStreak,
                maintained: widget.history.length,
                broken: _countBrokenDays(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Month navigator ──────────────────────────────────────────────────────
  Widget _monthNavigator() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.sm,
        vertical: AppSizes.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.border, width: 1.2),
      ),
      child: Row(
        children: [
          _navArrow(icon: Pixel.chevronleft, enabled: true, onTap: _prevMonth),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '${_monthName(_visibleMonth.month)} ${_visibleMonth.year}',
                textAlign: TextAlign.center,
                style: AppTextStyles.h3.copyWith(letterSpacing: 1.2),
              ),
            ),
          ),
          _navArrow(
            icon: Pixel.chevronright,
            enabled: _canGoForward,
            onTap: _nextMonth,
          ),
        ],
      ),
    );
  }

  Widget _navArrow({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: enabled ? onTap : null,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(
          icon,
          size: 20,
          color: enabled ? AppColors.textPrimary : AppColors.textMuted,
        ),
      ),
    );
  }

  // ── Calendar grid ────────────────────────────────────────────────────────
  Widget _calendarGrid() {
    final firstOfMonth = DateTime(_visibleMonth.year, _visibleMonth.month, 1);
    final daysInMonth = DateTime(
      _visibleMonth.year,
      _visibleMonth.month + 1,
      0,
    ).day;
    final leadingEmpty = firstOfMonth.weekday % 7; // Sunday = 0
    final totalCells = leadingEmpty + daysInMonth;
    final trailingEmpty = (7 - (totalCells % 7)) % 7;
    final gridCells = totalCells + trailingEmpty;
    final weeks = gridCells ~/ 7;

    return Column(
      children: List.generate(weeks, (week) {
        return Row(
          children: List.generate(7, (col) {
            final index = week * 7 + col;
            final dayNumber = index - leadingEmpty + 1;
            final inMonth = dayNumber >= 1 && dayNumber <= daysInMonth;
            return Expanded(
              child: AspectRatio(
                aspectRatio: 1,
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: inMonth
                      ? _dayCell(
                          DateTime(
                            _visibleMonth.year,
                            _visibleMonth.month,
                            dayNumber,
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            );
          }),
        );
      }),
    );
  }

  Widget _dayCell(DateTime date) {
    final iso = _iso(date);
    final inHistory = widget.history.contains(iso);
    final isFuture = _isFuture(date);
    final isToday = _isToday(date);
    final firstActive = _firstActive;

    // ── Determine cell state ──
    _CellState state;
    if (isFuture) {
      state = _CellState.future;
    } else if (inHistory) {
      state = _CellState.maintained;
    } else if (isToday) {
      state = _CellState.today;
    } else if (firstActive != null && !date.isBefore(firstActive)) {
      state = _CellState.broken;
    } else {
      state = _CellState.neutral;
    }

    // ── Style per state ──
    Color bg;
    Color border;
    Color fg;
    double borderWidth = 1;

    switch (state) {
      case _CellState.maintained:
        bg = AppColors.xpGreen.withValues(alpha: 0.18);
        border = AppColors.xpGreen;
        fg = AppColors.xpGreen;
        borderWidth = 1.5;
      case _CellState.broken:
        bg = AppColors.accentDanger.withValues(alpha: 0.15);
        border = AppColors.accentDanger;
        fg = AppColors.accentDanger;
        borderWidth = 1.5;
      case _CellState.today:
        bg = AppColors.secondary.withValues(alpha: 0.18);
        border = AppColors.secondary;
        fg = AppColors.textPrimary;
        borderWidth = 2;
      case _CellState.future:
        bg = Colors.transparent;
        border = AppColors.border;
        fg = AppColors.textMuted;
      case _CellState.neutral:
        bg = Colors.transparent;
        border = AppColors.border;
        fg = AppColors.textSecondary;
    }

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: border, width: borderWidth),
      ),
      child: Stack(
        children: [
          // Day number top-left
          Positioned(
            top: 3,
            left: 4,
            child: Text(
              date.day.toString(),
              style: AppTextStyles.micro.copyWith(
                color: fg,
                fontSize: 7,
                letterSpacing: 0,
              ),
            ),
          ),
          // Status indicator centered
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: _statusIcon(state),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusIcon(_CellState state) {
    switch (state) {
      case _CellState.maintained:
        return const Icon(Pixel.check, color: AppColors.xpGreen, size: 14);
      case _CellState.broken:
        return const Icon(Pixel.close, color: AppColors.accentDanger, size: 14);
      case _CellState.today:
        return const Icon(Pixel.zap, color: AppColors.secondary, size: 12);
      case _CellState.future:
      case _CellState.neutral:
        return const SizedBox.shrink();
    }
  }

  int _countBrokenDays() {
    final firstActive = _firstActive;
    if (firstActive == null) return 0;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    int count = 0;
    DateTime cursor = firstActive;
    while (cursor.isBefore(today)) {
      if (!widget.history.contains(_iso(cursor))) count++;
      cursor = cursor.add(const Duration(days: 1));
    }
    return count;
  }
}

enum _CellState { maintained, broken, today, future, neutral }
