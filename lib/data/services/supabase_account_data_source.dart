import 'package:debator/data/services/account_data_source.dart';
import 'package:debator/domain/models/viewer_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAccountDataSource implements AccountDataSource {
  SupabaseAccountDataSource({required SupabaseClient client}) : _client = client;

  final SupabaseClient _client;

  @override
  User? get currentUser => _client.auth.currentUser;

  @override
  Stream<User?> authStateChanges() {
    return _client.auth.onAuthStateChange.map((event) => event.session?.user);
  }

  @override
  Future<void> sendMagicLink({required String email, String? redirectTo}) async {
    await _client.auth.signInWithOtp(
      email: email,
      emailRedirectTo: redirectTo,
    );
  }

  @override
  Future<void> signOut() {
    return _client.auth.signOut();
  }

  @override
  Future<ViewerProfile?> fetchViewerProfile() async {
    final user = currentUser;
    if (user == null) {
      return null;
    }

    final row = await _client
        .from('profiles')
        .select('id, handle, display_name, avatar_url, rating')
        .eq('id', user.id)
        .maybeSingle();

    if (row == null) {
      return null;
    }

    return _mapProfile(row, email: user.email ?? '');
  }

  @override
  Future<ViewerProfile> completeOnboarding({
    required String displayName,
    required String handle,
  }) async {
    final user = currentUser;
    if (user == null) {
      throw StateError('No signed-in user was found.');
    }

    final normalizedHandle = _normalizeHandle(handle);

    await _client.from('profiles').update({
      'display_name': displayName.trim(),
      'handle': normalizedHandle,
    }).eq('id', user.id);

    await _client.auth.updateUser(
      UserAttributes(
        data: <String, dynamic>{
          'display_name': displayName.trim(),
          'preferred_username': normalizedHandle.substring(1),
          'onboarding_completed': true,
        },
      ),
    );

    final row = await _client
        .from('profiles')
        .select('id, handle, display_name, avatar_url, rating')
        .eq('id', user.id)
        .single();

    return _mapProfile(row, email: user.email ?? '');
  }

  ViewerProfile _mapProfile(Map<String, dynamic> row, {required String email}) {
    return ViewerProfile(
      id: row['id'] as String,
      email: email,
      handle: row['handle'] as String,
      displayName: row['display_name'] as String,
      avatarUrl: row['avatar_url'] as String?,
      rating: (row['rating'] as int?) ?? 1200,
    );
  }

  String _normalizeHandle(String handle) {
    final normalized = handle.trim().toLowerCase();
    return normalized.startsWith('@') ? normalized : '@$normalized';
  }
}
