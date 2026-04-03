import 'package:debator/app/bootstrap.dart';
import 'package:debator/data/repositories/account_repository.dart';
import 'package:debator/data/repositories/debate_repository.dart';
import 'package:debator/domain/models/viewer_profile.dart';
import 'package:debator/features/home/debator_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final appBootstrapProvider = Provider<AppBootstrapResult>((ref) {
  throw UnimplementedError('App bootstrap overrides are missing.');
});

final appConfigProvider = Provider((ref) => ref.watch(appBootstrapProvider).config);

final debateRepositoryProvider = Provider<DebateRepository>(
  (ref) => ref.watch(appBootstrapProvider).debateRepository,
);

final accountRepositoryProvider = Provider<AccountRepository>(
  (ref) => ref.watch(appBootstrapProvider).accountRepository,
);

final debatorViewModelProvider = Provider<DebatorViewModel>((ref) {
  throw UnimplementedError('DebatorViewModel override is missing.');
});

final authStateProvider = StreamProvider<User?>((ref) {
  final repository = ref.watch(accountRepositoryProvider);
  final currentUser = repository.currentUser;
  final stream = repository.authStateChanges();

  if (currentUser == null) {
    return stream;
  }

  return Stream<User?>.multi((controller) {
    controller.add(currentUser);
    final subscription = stream.listen(
      controller.add,
      onError: controller.addError,
      onDone: controller.close,
    );
    ref.onDispose(subscription.cancel);
  });
});

final viewerProfileProvider = FutureProvider<ViewerProfile?>((ref) async {
  final user = await ref.watch(authStateProvider.future);
  if (user == null) {
    return null;
  }

  return ref.watch(accountRepositoryProvider).fetchViewerProfile();
});

final currentViewerProfileProvider = Provider<ViewerProfile?>((ref) {
  final config = ref.watch(appConfigProvider);
  if (config.isMock) {
    return ViewerProfile.demo;
  }

  return ref.watch(viewerProfileProvider).asData?.value;
});

final sessionControllerProvider = Provider<SessionController>(
  SessionController.new,
);

class SessionController {
  SessionController(this._ref);

  final Ref _ref;

  AccountRepository get _repository => _ref.read(accountRepositoryProvider);

  Future<void> sendMagicLink(String email) async {
    await _repository.sendMagicLink(email: email);
  }

  Future<void> signOut() async {
    await _repository.signOut();
    _ref.invalidate(authStateProvider);
    _ref.invalidate(viewerProfileProvider);
  }

  Future<void> completeOnboarding({
    required String displayName,
    required String handle,
  }) async {
    await _repository.completeOnboarding(
      displayName: displayName,
      handle: handle,
    );
    _ref.invalidate(viewerProfileProvider);
    _ref.invalidate(authStateProvider);
  }
}
