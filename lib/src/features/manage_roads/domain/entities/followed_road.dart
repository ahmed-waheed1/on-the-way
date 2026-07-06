import 'package:equatable/equatable.dart';

/// A road the user has chosen to follow for status updates.
class FollowedRoad extends Equatable {
  const FollowedRoad({required this.id, required this.name});

  final String id;
  final String name;

  @override
  List<Object?> get props => [id, name];
}
