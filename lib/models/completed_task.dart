import 'package:cloud_firestore/cloud_firestore.dart';

class CompletedWork {
  final String id;
  final String taskId; // Added taskId field
  final String taskName;
  final String employeeId;
  final String supervisorId;
  final List<String> imageUrls;
  final DateTime completedDate;

  CompletedWork({
    required this.id,
    required this.taskId, // Updated constructor
    required this.taskName,
    required this.employeeId,
    required this.supervisorId,
    required this.imageUrls,
    required this.completedDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'taskId': taskId, // Added taskId to JSON
      'taskName': taskName,
      'employeeId': employeeId,
      'supervisorId': supervisorId,
      'imageUrls': imageUrls,
      'completedDate': Timestamp.fromDate(completedDate).toDate(), // Convert DateTime to Timestamp
    };
  }

  factory CompletedWork.fromJson(Map<String, dynamic> map) {
    return CompletedWork(
      id: map['id'] ?? '',
      taskId: map['taskId'] ?? '', // Added taskId from JSON
      taskName: map['taskName'] ?? '',
      employeeId: map['employeeId'] ?? '',
      supervisorId: map['supervisorId'] ?? '',
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      completedDate: map['completedDate'] is Timestamp
          ? (map['completedDate'] as Timestamp).toDate()
          : DateTime.parse(map['completedDate'] ?? DateTime.now().toIso8601String()),
    );
  }

  CompletedWork copyWith({
    String? id,
    String? taskId, // Added taskId to copyWith
    String? taskName,
    String? employeeId,
    String? supervisorId,
    List<String>? imageUrls,
    DateTime? completedDate,
  }) {
    return CompletedWork(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId, // Added taskId to copyWith
      taskName: taskName ?? this.taskName,
      employeeId: employeeId ?? this.employeeId,
      supervisorId: supervisorId ?? this.supervisorId,
      imageUrls: imageUrls ?? this.imageUrls,
      completedDate: completedDate ?? this.completedDate,
    );
  }
}
