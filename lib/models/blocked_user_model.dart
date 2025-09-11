class BlockedUser {
  final String id;
  final String name;
  final String? avatarUrl; // Puede ser nulo si no hay avatar

  BlockedUser({
    required this.id,
    required this.name,
    this.avatarUrl,
  });
}