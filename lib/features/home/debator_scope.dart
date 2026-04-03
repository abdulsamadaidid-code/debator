import 'package:debator/features/home/debator_view_model.dart';
import 'package:flutter/widgets.dart';

class DebatorScope extends InheritedNotifier<DebatorViewModel> {
  const DebatorScope({
    super.key,
    required DebatorViewModel viewModel,
    required super.child,
  }) : super(notifier: viewModel);

  static DebatorViewModel of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<DebatorScope>();
    assert(scope != null, 'DebatorScope was not found in the widget tree.');
    return scope!.notifier!;
  }
}
