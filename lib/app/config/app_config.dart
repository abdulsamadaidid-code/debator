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
    required this.authCallbackScheme,
    required this.authCallbackHost,
  });

  final AppEnvironment environment;
  final String supabaseUrl;
  final String supabaseAnonKey;
  final String authCallbackScheme;
  final String authCallbackHost;

  static AppConfig fromEnvironment() {
    return AppConfig(
      environment: AppEnvironment.fromEnvironment(),
      supabaseUrl: const String.fromEnvironment('SUPABASE_URL'),
      supabaseAnonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
      authCallbackScheme: String.fromEnvironment(
        'DEBATOR_AUTH_CALLBACK_SCHEME',
        defaultValue: 'debator',
      ),
      authCallbackHost: String.fromEnvironment(
        'DEBATOR_AUTH_CALLBACK_HOST',
        defaultValue: 'login-callback',
      ),
    );
  }

  bool get isMock => environment == AppEnvironment.mock;
  bool get requiresSupabase => !isMock;
  bool get hasSupabaseCredentials =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  String get authCallbackUrl => '$authCallbackScheme://$authCallbackHost/';

  void validate() {
    if (requiresSupabase && !hasSupabaseCredentials) {
      throw StateError(
        'Debator is running in ${environment.value} mode, '
        'but Supabase credentials are missing.',
      );
    }
  }
}
