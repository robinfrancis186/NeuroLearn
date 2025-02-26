import 'package:flutter/foundation.dart';
import 'collaborative_user.dart';
import 'collaborative_message.dart';

@immutable
class CollaborativeSession {
  final String id;
  final String name;
  final String subject;
  final String creatorId;
  final String creatorName;
  final DateTime createdAt;
  bool _isActive;
  final List<CollaborativeUser> participants;
  final List<CollaborativeMessage> messages;

  CollaborativeSession({
    required this.id,
    required this.name,
    required this.subject,
    required this.creatorId,
    required this.creatorName,
    required this.createdAt,
    bool isActive = true,
    List<CollaborativeUser>? participants,
    List<CollaborativeMessage>? messages,
  }) : _isActive = isActive,
       participants = participants ?? [],
       messages = messages ?? [];

  bool get isActive => _isActive;
  set isActive(bool value) => _isActive = value;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'subject': subject,
      'creatorId': creatorId,
      'creatorName': creatorName,
      'createdAt': createdAt.toIso8601String(),
      'isActive': _isActive,
      'participants': participants.map((p) => p.toJson()).toList(),
      'messages': messages.map((m) => m.toJson()).toList(),
    };
  }

  factory CollaborativeSession.fromJson(Map<String, dynamic> json) {
    return CollaborativeSession(
      id: json['id'] as String,
      name: json['name'] as String,
      subject: json['subject'] as String,
      creatorId: json['creatorId'] as String,
      creatorName: json['creatorName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isActive: json['isActive'] as bool,
      participants: (json['participants'] as List)
          .map((p) => CollaborativeUser.fromJson(p as Map<String, dynamic>))
          .toList(),
      messages: (json['messages'] as List)
          .map((m) => CollaborativeMessage.fromJson(m as Map<String, dynamic>))
          .toList(),
    );
  }

  CollaborativeSession copyWith({
    String? id,
    String? name,
    String? subject,
    String? creatorId,
    String? creatorName,
    DateTime? createdAt,
    bool? isActive,
    List<CollaborativeUser>? participants,
    List<CollaborativeMessage>? messages,
  }) {
    return CollaborativeSession(
      id: id ?? this.id,
      name: name ?? this.name,
      subject: subject ?? this.subject,
      creatorId: creatorId ?? this.creatorId,
      creatorName: creatorName ?? this.creatorName,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this._isActive,
      participants: participants ?? this.participants,
      messages: messages ?? this.messages,
    );
  }
} 