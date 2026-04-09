import 'package:debator/data/services/account_data_source.dart';
import 'package:debator/domain/models/viewer_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AccountRepository {
  AccountRepository({required AccountDataSource dataSource})
    : _dataSource = dataSource;

  final AccountDataSource _dataSource;

  User? get currentUser => _dataSource.currentUser;

  Stream<User?> authStateChanges() => _dataSource.authStateChanges();

  Future<void> sendMagicLink({required String email, String? redirectTo}) {
    return _dataSource.sendMagicLink(email: email, redirectTo: redirectTo);
  }

  Future<void> signOut() => _dataSource.signOut();

  Future<ViewerProfile?> fetchViewerProfile() => _dataSource.fetchViewerProfile();

  Future<ViewerProfile> completeOnboarding({
    required String displayName,
    required String handle,
  }) {
    return _dataSource.completeOnboarding(
      displayName: displayName,
      handle: handle,
    );
  }

  bool isOnboardingComplete(User user) {
    final metadata = user.userMetadata;
    return metadata?['onboarding_completed'] == true;
  }
}
