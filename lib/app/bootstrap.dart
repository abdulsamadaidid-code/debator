import 'package:debator/app/config/supabase_env.dart';
import 'package:debator/data/repositories/debate_repository.dart';
import 'package:debator/data/services/mock_debate_data_source.dart';
import 'package:debator/data/services/supabase_debate_data_source.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppBootstrap {
  static bool _supabaseInitialized = false;

  static Future<DebateRepository> createRepository() async {
    if (!SupabaseEnv.shouldUseSupabase) {
      return DebateRepository(dataSource: MockDebateDataSource());
    }

    try {
      await _ensureSupabaseInitialized();

      return DebateRepository(
        dataSource: SupabaseDebateDataSource(client: Supabase.instance.client),
      );
    } catch (error, stackTrace) {
      debugPrint('Failed to initialize Supabase, falling back to mock data.');
      debugPrint('$error');
      debugPrintStack(stackTrace: stackTrace);

      return DebateRepository(dataSource: MockDebateDataSource());
    }
  }

  static Future<void> _ensureSupabaseInitialized() async {
    if (_supabaseInitialized) {
      return;
    }

    await Supabase.initialize(
      url: SupabaseEnv.url,
      anonKey: SupabaseEnv.anonKey,
    );
    _supabaseInitialized = true;
  }
}
