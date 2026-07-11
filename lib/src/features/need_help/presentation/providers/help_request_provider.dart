import 'dart:io';
import 'package:flutter_riverpod/legacy.dart';

import '../../domain/entities/help_type.dart';

class HelpRequestState {
  final HelpType? helpType;
  final String description;
  final String location;
  final double? latitude;
  final double? longitude;
  final int imageCount;
  final File? image;

  const HelpRequestState({
    this.helpType,
    this.description = '',
    this.location = '',
    this.latitude,
    this.longitude,
    this.imageCount = 0,
    this.image,
  });

  HelpRequestState copyWith({
    HelpType? helpType,
    String? description,
    String? location,
    double? latitude,
    double? longitude,
    int? imageCount,
    File? image,
  }) {
    return HelpRequestState(
      helpType: helpType ?? this.helpType,
      description: description ?? this.description,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      imageCount: imageCount ?? this.imageCount,
      image: image ?? this.image,
    );
  }
}

class HelpRequestNotifier extends StateNotifier<HelpRequestState> {
  HelpRequestNotifier() : super(const HelpRequestState());

  void setHelpType(HelpType type) => state = state.copyWith(helpType: type);
  void setDescription(String value) =>
      state = state.copyWith(description: value);
  void setLocation(String value, {double? latitude, double? longitude}) =>
      state = state.copyWith(
          location: value, latitude: latitude, longitude: longitude);
  void setImageCount(int count) => state = state.copyWith(imageCount: count);
  void setImage(File image) =>
      state = state.copyWith(image: image, imageCount: 1);
  void reset() => state = const HelpRequestState();
}

final helpRequestProvider =
    StateNotifierProvider<HelpRequestNotifier, HelpRequestState>(
  (ref) => HelpRequestNotifier(),
);
