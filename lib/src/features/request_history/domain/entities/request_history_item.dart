import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';

/// The kind of request a user previously submitted.
enum RequestType {
  accident,
  assistance;

  String get label => switch (this) {
        RequestType.accident => 'Accident Report',
        RequestType.assistance => 'Assistance Request',
      };

  IconData get icon => switch (this) {
        RequestType.accident => Icons.report_problem_outlined,
        RequestType.assistance => Icons.build_outlined,
      };
}

/// The lifecycle status of a request.
enum RequestStatus {
  pending,
  inProgress,
  completed,
  cancelled;

  String get label => switch (this) {
        RequestStatus.pending => 'Pending',
        RequestStatus.inProgress => 'In Progress',
        RequestStatus.completed => 'Completed',
        RequestStatus.cancelled => 'Cancelled',
      };

  Color get badgeBg => switch (this) {
        RequestStatus.pending => AppColors.statusPendingBg,
        RequestStatus.inProgress => AppColors.statusInProgressBg,
        RequestStatus.completed => AppColors.statusCompletedBg,
        RequestStatus.cancelled => AppColors.statusCancelledBg,
      };

  Color get badgeTextColor => switch (this) {
        RequestStatus.pending => AppColors.statusPendingText,
        RequestStatus.inProgress => AppColors.statusInProgressText,
        RequestStatus.completed => AppColors.statusCompletedText,
        RequestStatus.cancelled => AppColors.statusCancelledText,
      };

  /// Vivid accent colour used for the status row on the details header.
  Color get accentColor => switch (this) {
        RequestStatus.pending => AppColors.statusPendingAccent,
        RequestStatus.inProgress => AppColors.statusInProgressAccent,
        RequestStatus.completed => AppColors.statusCompletedAccent,
        RequestStatus.cancelled => AppColors.statusCancelledAccent,
      };

  IconData get icon => switch (this) {
        RequestStatus.pending => Icons.schedule,
        RequestStatus.inProgress => Icons.autorenew,
        RequestStatus.completed => Icons.check_circle_outline,
        RequestStatus.cancelled => Icons.cancel_outlined,
      };
}

class RequestHistoryItem extends Equatable {
  const RequestHistoryItem({
    required this.id,
    required this.type,
    required this.date,
    required this.location,
    required this.status,
    this.title,
    this.incidentType = '',
    this.description = '',
    this.contactNumber = '',
  });

  final String id;
  final RequestType type;
  final DateTime date;
  final String location;
  final RequestStatus status;

  /// Header title on the details screen, e.g. "Flat Tire Assistance".
  /// Falls back to [RequestType.label] when not provided.
  final String? title;

  /// The specific incident, e.g. "Flat Tire" or "Crash".
  final String incidentType;

  /// Free-text description supplied when the request was created.
  final String description;

  /// Contact number associated with the request.
  final String contactNumber;

  String get displayTitle => title ?? type.label;

  @override
  List<Object?> get props =>
      [id, type, date, location, status, title, incidentType, description, contactNumber];
}
