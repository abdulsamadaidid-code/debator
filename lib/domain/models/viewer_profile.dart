class ViewerProfile {
  const ViewerProfile({
    required this.id,
    required this.email,
    required this.handle,
    required this.displayName,
    required this.rating,
    this.avatarUrl,
  });

  final String id;
  final String email;
  final String handle;
  final String displayName;
  final int rating;
  final String? avatarUrl;

  String get firstName {
    final trimmed = displayName.trim();
    if (trimmed.isEmpty) {
      return 'Debator';
    }
    return trimmed.split(RegExp(r'\s+')).first;
  }
}
