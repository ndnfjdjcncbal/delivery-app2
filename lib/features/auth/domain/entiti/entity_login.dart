class User {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? image;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.image,
  });
}
