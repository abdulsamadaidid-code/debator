import 'package:debator/app/config/app_config.dart';
import 'package:debator/data/repositories/account_repository.dart';
import 'package:debator/data/repositories/debate_repository.dart';
import 'package:debator/data/services/mock_account_data_source.dart';
import 'package:debator/data/services/mock_debate_data_source.dart';
import 'package:debator/data/services/supabase_account_data_source.dart';
import 'package:debator/data/services/supabase_debate_data_source.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppBootstrap {
  static bool _supabaseInitialized = false;

  static Future<AppBootstrapResult> create() async {
    final config = AppConfig.fromEnvironment();
    config.validate();

    if (config.isMock) {
      return AppBootstrapResult(
        config: config,
        debateRepository: DebateRepository(dataSource: MockDebateDataSource()),
        accountRepository: AccountRepository(
          dataSource: MockAccountDataSource(),
        ),
      );
    }

    await _ensureSupabaseInitialized(config);

    final client = Supabase.instance.client;
    return AppBootstrapResult(
      config: config,
      debateRepository: DebateRepository(
        dataSource: SupabaseDebateDataSource(client: client),
      ),
      accountRepository: AccountRepository(
        dataSource: SupabaseAccountDataSource(client: client),
      ),
    );
  }

  static Future<void> _ensureSupabaseInitialized(AppConfig config) async {
    if (_supabaseInitialized) {
      return;
    }

    try {
      await Supabase.initialize(
        url: config.supabaseUrl,
        anonKey: config.supabaseAnonKey,
      );
    } catch (error, stackTrace) {
      debugPrint('Failed to initialize Supabase.');
      debugPrint('$error');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
    _supabaseInitialized = true;
  }
}

class AppBootstrapResult {
  const AppBootstrapResult({
    required this.config,
    required this.debateRepository,
    required this.accountRepository,
  });

  final AppConfig config;
  final DebateRepository debateRepository;
  final AccountRepository accountRepository;
}
