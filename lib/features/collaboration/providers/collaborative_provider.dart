import 'package:flutter/foundation.dart';

class CollaborativeMessage {
  final String id;
  final String content;
  final String senderId;
  final String senderName;
  final DateTime timestamp;

  CollaborativeMessage({
    required this.id,
    required this.content,
    required this.senderId,
    required this.senderName,
    required this.timestamp,
  });
}

class CollaborativeSession {
  final String id;
  final String name;
  final String subject;
  final String creatorName;
  final List<String> participants;
  final List<CollaborativeMessage> messages;
  final DateTime createdAt;

  CollaborativeSession({
    required this.id,
    required this.name,
    required this.subject,
    required this.creatorName,
    required this.participants,
    required this.messages,
    required this.createdAt,
  });
}

class CollaborativeProvider extends ChangeNotifier {
  String? _currentUserId;
  CollaborativeSession? _currentSession;
  final List<CollaborativeSession> _sessions = [];

  // Getters
  String? get currentUserId => _currentUserId;
  CollaborativeSession? get currentSession => _currentSession;
  List<CollaborativeSession> get sessions => List.unmodifiable(_sessions);

  // Methods
  Future<void> initialize(String userId) async {
    _currentUserId = userId;
    notifyListeners();
  }

  Future<String> createSession({
    required String name,
    required String subject,
    required List<String> participants,
    required String creatorName,
  }) async {
    final session = CollaborativeSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      subject: subject,
      creatorName: creatorName,
      participants: participants,
      messages: [],
      createdAt: DateTime.now(),
    );

    _sessions.add(session);
    notifyListeners();
    return session.id;
  }

  Future<void> joinSession(String sessionId) async {
    final session = _sessions.firstWhere(
      (s) => s.id == sessionId,
      orElse: () => throw Exception('Session not found'),
    );

    if (!session.participants.contains(_currentUserId)) {
      final updatedParticipants = List<String>.from(session.participants)
        ..add(_currentUserId!);

      final updatedSession = CollaborativeSession(
        id: session.id,
        name: session.name,
        subject: session.subject,
        creatorName: session.creatorName,
        participants: updatedParticipants,
        messages: session.messages,
        createdAt: session.createdAt,
      );

      final index = _sessions.indexWhere((s) => s.id == sessionId);
      _sessions[index] = updatedSession;
    }

    _currentSession = session;
    notifyListeners();
  }

  Future<void> leaveSession(String sessionId) async {
    if (_currentSession?.id != sessionId) return;

    final session = _sessions.firstWhere(
      (s) => s.id == sessionId,
      orElse: () => throw Exception('Session not found'),
    );

    if (session.participants.contains(_currentUserId)) {
      final updatedParticipants = List<String>.from(session.participants)
        ..remove(_currentUserId);

      if (updatedParticipants.isEmpty) {
        _sessions.removeWhere((s) => s.id == sessionId);
      } else {
        final updatedSession = CollaborativeSession(
          id: session.id,
          name: session.name,
          subject: session.subject,
          creatorName: session.creatorName,
          participants: updatedParticipants,
          messages: session.messages,
          createdAt: session.createdAt,
        );

        final index = _sessions.indexWhere((s) => s.id == sessionId);
        _sessions[index] = updatedSession;
      }
    }

    _currentSession = null;
    notifyListeners();
  }

  Future<void> sendMessage(String sessionId, String content) async {
    if (_currentUserId == null) throw Exception('User not initialized');

    final session = _sessions.firstWhere(
      (s) => s.id == sessionId,
      orElse: () => throw Exception('Session not found'),
    );

    final message = CollaborativeMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      senderId: _currentUserId!,
      senderName: _currentUserId!,
      timestamp: DateTime.now(),
    );

    final updatedMessages = List<CollaborativeMessage>.from(session.messages)
      ..add(message);

    final updatedSession = CollaborativeSession(
      id: session.id,
      name: session.name,
      subject: session.subject,
      creatorName: session.creatorName,
      participants: session.participants,
      messages: updatedMessages,
      createdAt: session.createdAt,
    );

    final index = _sessions.indexWhere((s) => s.id == sessionId);
    _sessions[index] = updatedSession;
    _currentSession = updatedSession;
    notifyListeners();
  }

  Future<void> fetchAvailableSessions() async {
    // In a real app, this would fetch sessions from a backend
    // For now, we'll just notify listeners to refresh the UI
    notifyListeners();
  }
} 