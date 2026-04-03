import 'dart:async';

import 'package:debator/app/theme/app_theme.dart';
import 'package:debator/data/repositories/debate_repository.dart';
import 'package:debator/features/home/debator_home_shell.dart';
import 'package:debator/features/home/debator_scope.dart';
import 'package:debator/features/home/debator_view_model.dart';
import 'package:flutter/material.dart';

class DebatorApp extends StatefulWidget {
  const DebatorApp({super.key, required this.repository});

  final DebateRepository repository;

  @override
  State<DebatorApp> createState() => _DebatorAppState();
}

class _DebatorAppState extends State<DebatorApp> {
  late final DebatorViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = DebatorViewModel(repository: widget.repository);
    unawaited(_viewModel.initialize());
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DebatorScope(
      viewModel: _viewModel,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Debator',
        theme: AppTheme.light(),
        home: const DebatorHomeShell(),
      ),
    );
  }
}
