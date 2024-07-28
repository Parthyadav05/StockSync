import 'package:cloud_firestore/cloud_firestore.dart';

class Tasks {
  final String id;
  final String description;
  final String assignedTo; // Employee ID
  final String assignedBy; // Supervisor ID
  final String status;
  final DateTime? assignedDate;

  Tasks({
    required this.id,
    required this.description,
    required this.assignedTo,
    required this.assignedBy,
    required this.status,
    this.assignedDate,
  });

  factory Tasks.fromJson(Map<String, dynamic> json) {
    return Tasks(
      id: json['id'],
      description: json['description'],
      assignedTo: json['assignedTo'],
      assignedBy: json['assignedBy'],
      status: json['status'],
      assignedDate: json['assignedDate'] is Timestamp
          ? (json['assignedDate'] as Timestamp).toDate()
          : json['assignedDate'] != null
          ? DateTime.parse(json['assignedDate'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'assignedTo': assignedTo,
      'assignedBy': assignedBy,
      'status': status,
      'assignedDate': assignedDate != null ? Timestamp.fromDate(assignedDate!) : null,
    };
  }
}
