import 'package:equatable/equatable.dart';

class AppUser extends Equatable {
  final String id;
  final String email;
  final String? name;
  final String? photoUrl;
  final String? phone;
  final String? username;
  final String? bio;

  const AppUser({
    required this.id,
    required this.email,
    this.name,
    this.photoUrl,
    this.phone,
    this.username,
    this.bio,
  });

  AppUser copyWith({
    String? id,
    String? email,
    String? name,
    String? photoUrl,
    String? phone,
    String? username,
    String? bio,
  }) =>
      AppUser(
        id: id ?? this.id,
        email: email ?? this.email,
        name: name ?? this.name,
        photoUrl: photoUrl ?? this.photoUrl,
        phone: phone ?? this.phone,
        username: username ?? this.username,
        bio: bio ?? this.bio,
      );

  factory AppUser.empty() => const AppUser(id: '', email: '');

  bool get isEmpty => id.isEmpty;
  bool get isNotEmpty => id.isNotEmpty;

  @override
  List<Object?> get props => [id, email, name, photoUrl, phone, username, bio];
}
