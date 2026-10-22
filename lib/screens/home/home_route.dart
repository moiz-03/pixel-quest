import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/home_view_model.dart';
import 'home_screen.dart';

/// Wraps [HomeScreen] in its [HomeViewModel] provider so any route that
/// navigates to Home gets a fully wired screen.
Widget homeRoute() {
  return ChangeNotifierProvider(
    create: (_) => HomeViewModel()..bootstrap(),
    child: const HomeScreen(),
  );
}
