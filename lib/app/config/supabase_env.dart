class SupabaseEnv {
  static const String url = String.fromEnvironment('SUPABASE_URL');
  static const String anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const bool useSupabase = bool.fromEnvironment(
    'DEBATOR_USE_SUPABASE',
    defaultValue: false,
  );

  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;

  static bool get shouldUseSupabase => useSupabase && isConfigured;
}
