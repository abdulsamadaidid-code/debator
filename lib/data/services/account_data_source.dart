import 'package:debator/domain/models/viewer_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AccountDataSource {
  User? get currentUser;

  Stream<User?> authStateChanges();

  Future<void> sendMagicLink({required String email});

  Future<void> signOut();

  Future<ViewerProfile?> fetchViewerProfile();

  Future<ViewerProfile> completeOnboarding({
    required String displayName,
    required String handle,
  });
}
