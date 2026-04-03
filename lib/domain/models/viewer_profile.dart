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

  static const ViewerProfile demo = ViewerProfile(
    id: 'demo-viewer',
    email: 'demo@debator.app',
    handle: '@you',
    displayName: 'You',
    rating: 1280,
  );

  String get firstName {
    final trimmed = displayName.trim();
    if (trimmed.isEmpty) {
      return 'Debator';
    }
    return trimmed.split(RegExp(r'\s+')).first;
  }
}
