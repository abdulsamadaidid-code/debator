import 'package:debator/data/services/account_data_source.dart';
import 'package:debator/domain/models/viewer_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockAccountDataSource implements AccountDataSource {
  @override
  User? get currentUser => null;

  @override
  Stream<User?> authStateChanges() => Stream<User?>.value(null);

  @override
  Future<ViewerProfile> completeOnboarding({
    required String displayName,
    required String handle,
  }) {
    throw StateError('Onboarding is unavailable in mock mode.');
  }

  @override
  Future<ViewerProfile?> fetchViewerProfile() async => null;

  @override
  Future<void> sendMagicLink({required String email, String? redirectTo}) {
    throw StateError('Authentication is unavailable in mock mode.');
  }

  @override
  Future<void> signOut() async {}
}
