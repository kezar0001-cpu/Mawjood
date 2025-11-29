import 'package:flutter/foundation.dart';

enum ClaimStatus {
  pending,
  approved,
  rejected;

  String get displayName {
    switch (this) {
      case ClaimStatus.pending:
        return 'قيد المراجعة';
      case ClaimStatus.approved:
        return 'تمت الموافقة';
      case ClaimStatus.rejected:
        return 'مرفوض';
    }
  }
}

@immutable
class BusinessClaim {
  final String id;
  final String businessId;
  final String userId;
  final String userName;
  final String userEmail;
  final String? userPhone;
  final List<String> proofDocuments;
  final ClaimStatus status;
  final String? adminNotes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BusinessClaim({
    required this.id,
    required this.businessId,
    required this.userId,
    required this.userName,
    required this.userEmail,
    this.userPhone,
    this.proofDocuments = const [],
    this.status = ClaimStatus.pending,
    this.adminNotes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BusinessClaim.fromMap(Map<String, dynamic> map) {
    return BusinessClaim(
      id: map['id'] as String,
      businessId: map['business_id'] as String,
      userId: map['user_id'] as String,
      userName: map['user_name'] as String,
      userEmail: map['user_email'] as String,
      userPhone: map['user_phone'] as String?,
      proofDocuments: map['proof_documents'] != null
          ? List<String>.from(map['proof_documents'])
          : const [],
      status: _parseStatus(map['status'] as String),
      adminNotes: map['admin_notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  static ClaimStatus _parseStatus(String status) {
    switch (status) {
      case 'approved':
        return ClaimStatus.approved;
      case 'rejected':
        return ClaimStatus.rejected;
      default:
        return ClaimStatus.pending;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'business_id': businessId,
      'user_id': userId,
      'user_name': userName,
      'user_email': userEmail,
      'user_phone': userPhone,
      'proof_documents': proofDocuments,
      'status': status.name,
      'admin_notes': adminNotes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  BusinessClaim copyWith({
    String? id,
    String? businessId,
    String? userId,
    String? userName,
    String? userEmail,
    String? userPhone,
    List<String>? proofDocuments,
    ClaimStatus? status,
    String? adminNotes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BusinessClaim(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      userPhone: userPhone ?? this.userPhone,
      proofDocuments: proofDocuments ?? this.proofDocuments,
      status: status ?? this.status,
      adminNotes: adminNotes ?? this.adminNotes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
