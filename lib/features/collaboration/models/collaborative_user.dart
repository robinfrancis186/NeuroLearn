import 'package:flutter/foundation.dart';

@immutable
class CollaborativeUser {
  final String id;
  final String name;
  final String avatarUrl;
  final bool isOnline;
  DateTime _lastActive;

  CollaborativeUser({
    required this.id,
    required this.name,
    this.avatarUrl = '',
    this.isOnline = false,
    DateTime? lastActive,
  }) : _lastActive = lastActive ?? DateTime.now();

  DateTime get lastActive => _lastActive;
  set lastActive(DateTime value) => _lastActive = value;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatarUrl': avatarUrl,
      'isOnline': isOnline,
      'lastActive': _lastActive.toIso8601String(),
    };
  }

  factory CollaborativeUser.fromJson(Map<String, dynamic> json) {
    return CollaborativeUser(
      id: json['id'] as String,
      name: json['name'] as String,
      avatarUrl: json['avatarUrl'] as String? ?? '',
      isOnline: json['isOnline'] as bool? ?? false,
      lastActive: DateTime.parse(json['lastActive'] as String),
    );
  }

  CollaborativeUser copyWith({
    String? id,
    String? name,
    String? avatarUrl,
    bool? isOnline,
    DateTime? lastActive,
  }) {
    return CollaborativeUser(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isOnline: isOnline ?? this.isOnline,
      lastActive: lastActive ?? this._lastActive,
    );
  }
} 