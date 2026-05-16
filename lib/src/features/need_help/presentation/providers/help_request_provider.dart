import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../domain/entities/help_type.dart';

class HelpRequestState {
  final HelpType? helpType;
  final String description;
  final String location;
  final int imageCount;

  const HelpRequestState({
    this.helpType,
    this.description = '',
    this.location = '',
    this.imageCount = 0,
  });

  HelpRequestState copyWith({
    HelpType? helpType,
    String? description,
    String? location,
    int? imageCount,
  }) {
    return HelpRequestState(
      helpType: helpType ?? this.helpType,
      description: description ?? this.description,
      location: location ?? this.location,
      imageCount: imageCount ?? this.imageCount,
    );
  }
}

class HelpRequestNotifier extends StateNotifier<HelpRequestState> {
  HelpRequestNotifier() : super(const HelpRequestState());

  void setHelpType(HelpType type) => state = state.copyWith(helpType: type);
  void setDescription(String value) => state = state.copyWith(description: value);
  void setLocation(String value) => state = state.copyWith(location: value);
  void setImageCount(int count) => state = state.copyWith(imageCount: count);
  void reset() => state = const HelpRequestState();
}

final helpRequestProvider =
    StateNotifierProvider<HelpRequestNotifier, HelpRequestState>(
  (ref) => HelpRequestNotifier(),
);
