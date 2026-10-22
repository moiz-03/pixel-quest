import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:pixelarticons/pixelarticons.dart';

import '../theme/app_colors.dart';
import '../utils/date_helper.dart';

enum QuestCategory {
  health(
    label: 'HEALTH',
    displayName: 'Health',
    icon: Pixel.drop,
    color: AppColors.badgeBlue,
  ),
  fitness(
    label: 'FITNESS',
    displayName: 'Fitness',
    icon: Pixel.humanrun,
    color: AppColors.badgePink,
  ),
  selfImprovement(
    label: 'SELF IMPROVEMENT',
    displayName: 'Self Improvement',
    icon: Pixel.bookopen,
    color: AppColors.badgePink,
  ),
  skills(
    label: 'SKILLS',
    displayName: 'Skills',
    icon: Pixel.code,
    color: AppColors.badgePurple,
  );

  const QuestCategory({
    required this.label,
    required this.displayName,
    required this.icon,
    required this.color,
  });

  final String label;
  final String displayName;
  final IconData icon;
  final Color color;
}

class Quest {
  Quest({
    required this.id,
    required this.title,
    required this.category,
    required this.xp,
    List<String>? completedDates,
    this.reminderTime,
  }) : _completedDates = List<String>.from(completedDates ?? const []);

  final String id;
  String title;
  QuestCategory category;
  int xp;

  /// Internal mutable storage. Never expose directly — mutate via
  /// [addCompletion] / [removeCompletion] so future listeners can hook in.
  final List<String> _completedDates;

  /// ISO dates ("YYYY-MM-DD") on which this quest was completed.
  /// Read-only view; use [addCompletion] / [removeCompletion] to change.
  List<String> get completedDates => UnmodifiableListView(_completedDates);

  /// Daily reminder time in "HH:mm" 24-hour format. null = no reminder.
  String? reminderTime;

  /// True if this quest has been completed today.
  bool get completed => _completedDates.contains(DateHelper.todayIso());

  // ── Completion mutators ──────────────────────────────────────────────────
  void addCompletion(String iso) {
    if (!_completedDates.contains(iso)) _completedDates.add(iso);
  }

  void removeCompletion(String iso) {
    _completedDates.remove(iso);
  }

  // ── Copy ─────────────────────────────────────────────────────────────────
  /// Returns a new [Quest] with the given fields replaced. Pass
  /// [clearReminder] = true to explicitly set [reminderTime] to null.
  Quest copyWith({
    String? title,
    QuestCategory? category,
    int? xp,
    String? reminderTime,
    bool clearReminder = false,
  }) {
    return Quest(
      id: id,
      title: title ?? this.title,
      category: category ?? this.category,
      xp: xp ?? this.xp,
      completedDates: List<String>.from(_completedDates),
      reminderTime: clearReminder ? null : (reminderTime ?? this.reminderTime),
    );
  }

  // ── Serialization ────────────────────────────────────────────────────────
  factory Quest.fromMap(String id, Map<String, dynamic> map) {
    final catName = map['category']?.toString();
    final category = QuestCategory.values.firstWhere(
      (c) => c.name == catName,
      orElse: () => QuestCategory.health,
    );

    // Parse completedDates. If the field is missing, migrate from the
    // legacy `completed` boolean.
    List<String> completedDates;
    final rawDates = map['completedDates'];
    if (rawDates is List) {
      completedDates = rawDates.whereType<String>().toList();
    } else {
      final legacy = _parseBool(map['completed'], fallback: false);
      completedDates = legacy ? [DateHelper.todayIso()] : [];
    }

    return Quest(
      id: id.isNotEmpty ? id : (map['id'] ?? '').toString(),
      title: (map['title'] ?? '').toString(),
      category: category,
      xp: _parseInt(map['xp'], fallback: 10),
      completedDates: completedDates,
      reminderTime: _parseString(map['reminderTime']),
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'category': category.name,
    'xp': xp,
    // Return a plain copy so Firestore serialization sees a real List.
    'completedDates': List<String>.from(_completedDates),
    'reminderTime': reminderTime,
  };

  // ── Tolerant parsers ─────────────────────────────────────────────────────
  static int _parseInt(Object? v, {required int fallback}) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? fallback;
    return fallback;
  }

  static bool _parseBool(Object? v, {required bool fallback}) {
    if (v is bool) return v;
    if (v is String) {
      if (v.toLowerCase() == 'true') return true;
      if (v.toLowerCase() == 'false') return false;
    }
    return fallback;
  }

  static String? _parseString(Object? v) {
    if (v == null) return null;
    if (v is String) return v.isEmpty ? null : v;
    return v.toString();
  }
}
