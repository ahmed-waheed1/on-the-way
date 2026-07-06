import 'package:flutter_riverpod/legacy.dart';

import '../../../nearby_accidents/domain/entities/accident_report.dart';

/// Draft state for the multi-step "Report Accident" flow.
class AccidentReportDraft {
  final AccidentType? type;
  final DateTime? date;
  final String location;
  final String description;
  final int imageCount;
  final String phoneNumber;

  const AccidentReportDraft({
    this.type,
    this.date,
    this.location = '',
    this.description = '',
    this.imageCount = 0,
    this.phoneNumber = '',
  });

  bool get isStepOneComplete => type != null && date != null && location.isNotEmpty;

  bool get isStepTwoComplete => description.isNotEmpty && phoneNumber.isNotEmpty;

  AccidentReportDraft copyWith({
    AccidentType? type,
    DateTime? date,
    String? location,
    String? description,
    int? imageCount,
    String? phoneNumber,
  }) {
    return AccidentReportDraft(
      type: type ?? this.type,
      date: date ?? this.date,
      location: location ?? this.location,
      description: description ?? this.description,
      imageCount: imageCount ?? this.imageCount,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }
}

class AccidentReportNotifier extends StateNotifier<AccidentReportDraft> {
  AccidentReportNotifier() : super(const AccidentReportDraft());

  void setType(AccidentType type) => state = state.copyWith(type: type);
  void setDate(DateTime date) => state = state.copyWith(date: date);
  void setLocation(String value) => state = state.copyWith(location: value);
  void setDescription(String value) => state = state.copyWith(description: value);
  void setImageCount(int count) => state = state.copyWith(imageCount: count);
  void setPhoneNumber(String value) => state = state.copyWith(phoneNumber: value);
  void reset() => state = const AccidentReportDraft();
}

final accidentReportProvider =
    StateNotifierProvider<AccidentReportNotifier, AccidentReportDraft>(
  (ref) => AccidentReportNotifier(),
);
