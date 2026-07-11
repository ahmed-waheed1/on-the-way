import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';

/// Splits a PascalCase API enum name into words, e.g. "RoadClosure" → "Road Closure".
String humanizeApiName(String name) {
  if (name.isEmpty) return name;
  return name.replaceAllMapped(RegExp(r'(?<=[a-z])(?=[A-Z])'), (_) => ' ');
}

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

  /// Maps the API `category` field ("Incident" / "Assistance").
  static RequestType fromCategory(String? category) {
    return (category ?? '').toLowerCase() == 'assistance'
        ? RequestType.assistance
        : RequestType.accident;
  }
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

  /// Maps the API `status` string to the closest lifecycle state.
  static RequestStatus fromApi(String? status) {
    final s = (status ?? '').toLowerCase().replaceAll(RegExp(r'[\s_]'), '');
    return switch (s) {
      'inprogress' ||
      'accepted' ||
      'active' ||
      'ongoing' =>
        RequestStatus.inProgress,
      'completed' ||
      'resolved' ||
      'done' ||
      'closed' =>
        RequestStatus.completed,
      'cancelled' ||
      'canceled' ||
      'rejected' ||
      'declined' =>
        RequestStatus.cancelled,
      _ => RequestStatus.pending, // pending / open / new / submitted
    };
  }
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
    this.imageUrl = '',
  });

  final String id;
  final RequestType type;
  final DateTime date;
  final String location;
  final RequestStatus status;

  /// Relative photo path from the detail endpoint, e.g. `/uploads/incidents/…`.
  /// Empty for list items (the history list has no image).
  final String imageUrl;

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

  /// A list item from GET /api/history
  /// `{ id, category, type, status, date, location }`.
  factory RequestHistoryItem.fromHistoryJson(Map<String, dynamic> json) {
    final typeName = humanizeApiName(json['type']?.toString() ?? '');
    return RequestHistoryItem(
      id: json['id']?.toString() ?? '',
      type: RequestType.fromCategory(json['category']?.toString()),
      date: DateTime.tryParse(json['date']?.toString() ?? '')?.toLocal() ??
          DateTime.now(),
      location: json['location']?.toString() ?? '',
      status: RequestStatus.fromApi(json['status']?.toString()),
      title: typeName,
      incidentType: typeName,
    );
  }

  /// Full record from GET /api/incidents/{id}.
  factory RequestHistoryItem.fromIncidentDetail(Map<String, dynamic> json) {
    final typeName = humanizeApiName(json['incidentType']?.toString() ?? '');
    return RequestHistoryItem(
      id: json['id']?.toString() ?? '',
      type: RequestType.accident,
      date: DateTime.tryParse(json['createdAt']?.toString() ?? '')?.toLocal() ??
          DateTime.now(),
      location: json['locationName']?.toString() ?? '',
      status: RequestStatus.fromApi(json['status']?.toString()),
      title: typeName,
      incidentType: typeName,
      description: json['description']?.toString() ?? '',
      contactNumber: json['phoneNumber']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
    );
  }

  /// Full record from GET /api/assistance/{id}.
  factory RequestHistoryItem.fromAssistanceDetail(Map<String, dynamic> json) {
    final typeName = humanizeApiName(json['helpType']?.toString() ?? '');
    return RequestHistoryItem(
      id: json['id']?.toString() ?? '',
      type: RequestType.assistance,
      date: DateTime.tryParse(json['createdAt']?.toString() ?? '')?.toLocal() ??
          DateTime.now(),
      location: json['address']?.toString() ?? '',
      status: RequestStatus.fromApi(json['status']?.toString()),
      title: typeName,
      incidentType: typeName,
      description: json['description']?.toString() ?? '',
      contactNumber: json['contactNumber']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
    );
  }

  @override
  List<Object?> get props => [
        id,
        type,
        date,
        location,
        status,
        title,
        incidentType,
        description,
        contactNumber,
        imageUrl
      ];
}
