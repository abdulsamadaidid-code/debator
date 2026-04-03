enum AppEnvironment {
  mock('mock'),
  staging('staging'),
  production('production');

  const AppEnvironment(this.value);

  final String value;

  static AppEnvironment fromEnvironment() {
    const rawValue = String.fromEnvironment('DEBATOR_ENV');
    if (rawValue.isNotEmpty) {
      return values.firstWhere(
        (environment) => environment.value == rawValue,
        orElse: () => throw StateError(
          'Unsupported DEBATOR_ENV value "$rawValue". '
          'Expected one of: mock, staging, production.',
        ),
      );
    }

    const legacySupabaseFlag = bool.fromEnvironment(
      'DEBATOR_USE_SUPABASE',
      defaultValue: false,
    );
    return legacySupabaseFlag ? AppEnvironment.staging : AppEnvironment.mock;
  }
}

class AppConfig {
  const AppConfig({
    required this.environment,
    required this.supabaseUrl,
    required this.supabaseAnonKey,
  });

  final AppEnvironment environment;
  final String supabaseUrl;
  final String supabaseAnonKey;

  static AppConfig fromEnvironment() {
    return AppConfig(
      environment: AppEnvironment.fromEnvironment(),
      supabaseUrl: const String.fromEnvironment('SUPABASE_URL'),
      supabaseAnonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
    );
  }

  bool get isMock => environment == AppEnvironment.mock;
  bool get requiresSupabase => !isMock;
  bool get hasSupabaseCredentials =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  void validate() {
    if (requiresSupabase && !hasSupabaseCredentials) {
      throw StateError(
        'Debator is running in ${environment.value} mode, '
        'but Supabase credentials are missing.',
      );
    }
  }
}
