import 'package:debator/app/bootstrap.dart';
import 'package:debator/app/providers/app_providers.dart';
import 'package:debator/app/router/app_router.dart';
import 'package:debator/app/theme/app_theme.dart';
import 'package:debator/features/home/debator_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DebatorApp extends StatefulWidget {
  const DebatorApp({super.key, required this.bootstrap});

  final AppBootstrapResult bootstrap;

  @override
  State<DebatorApp> createState() => _DebatorAppState();
}

class _DebatorAppState extends State<DebatorApp> {
  late final DebatorViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = DebatorViewModel(
      repository: widget.bootstrap.debateRepository,
    );
    _viewModel.initialize();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        appBootstrapProvider.overrideWithValue(widget.bootstrap),
        debatorViewModelProvider.overrideWithValue(_viewModel),
      ],
      child: const _DebatorRoot(),
    );
  }
}

class _DebatorRoot extends ConsumerWidget {
  const _DebatorRoot();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Debator',
      theme: AppTheme.light(),
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
