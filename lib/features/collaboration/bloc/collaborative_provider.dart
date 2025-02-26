import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Model class for a collaborative session
class CollaborativeSession {
  final String id;
  final String name;
  final String subject;
  final String creatorId;
  final String creatorName;
  final DateTime createdAt;
  final List<CollaborativeUser> participants;
  final List<CollaborativeMessage> messages;
  final bool isActive;

  CollaborativeSession({
    required this.id,
    required this.name,
    required this.subject,
    required this.creatorId,
    required this.creatorName,
    required this.createdAt,
    required this.participants,
    required this.messages,
    this.isActive = true,
  });

  CollaborativeSession copyWith({
    String? id,
    String? name,
    String? subject,
    String? creatorId,
    String? creatorName,
    DateTime? createdAt,
    List<CollaborativeUser>? participants,
    List<CollaborativeMessage>? messages,
    bool? isActive,
  }) {
    return CollaborativeSession(
      id: id ?? this.id,
      name: name ?? this.name,
      subject: subject ?? this.subject,
      creatorId: creatorId ?? this.creatorId,
      creatorName: creatorName ?? this.creatorName,
      createdAt: createdAt ?? this.createdAt,
      participants: participants ?? this.participants,
      messages: messages ?? this.messages,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'subject': subject,
      'creatorId': creatorId,
      'creatorName': creatorName,
      'createdAt': createdAt.toIso8601String(),
      'participants': participants.map((p) => p.toJson()).toList(),
      'messages': messages.map((m) => m.toJson()).toList(),
      'isActive': isActive,
    };
  }

  factory CollaborativeSession.fromJson(Map<String, dynamic> json) {
    return CollaborativeSession(
      id: json['id'],
      name: json['name'],
      subject: json['subject'],
      creatorId: json['creatorId'],
      creatorName: json['creatorName'],
      createdAt: DateTime.parse(json['createdAt']),
      participants: (json['participants'] as List)
          .map((p) => CollaborativeUser.fromJson(p))
          .toList(),
      messages: (json['messages'] as List)
          .map((m) => CollaborativeMessage.fromJson(m))
          .toList(),
      isActive: json['isActive'],
    );
  }
}

/// Model class for a user in a collaborative session
class CollaborativeUser {
  final String id;
  final String name;
  final String avatarUrl;
  final bool isOnline;
  final DateTime lastActive;

  CollaborativeUser({
    required this.id,
    required this.name,
    this.avatarUrl = '',
    this.isOnline = true,
    required this.lastActive,
  });

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
      lastActive: lastActive ?? this.lastActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatarUrl': avatarUrl,
      'isOnline': isOnline,
      'lastActive': lastActive.toIso8601String(),
    };
  }

  factory CollaborativeUser.fromJson(Map<String, dynamic> json) {
    return CollaborativeUser(
      id: json['id'],
      name: json['name'],
      avatarUrl: json['avatarUrl'],
      isOnline: json['isOnline'],
      lastActive: DateTime.parse(json['lastActive']),
    );
  }
}

/// Model class for a message in a collaborative session
class CollaborativeMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime timestamp;
  final MessageType type;
  final Map<String, dynamic>? metadata;

  CollaborativeMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.timestamp,
    this.type = MessageType.text,
    this.metadata,
  });

  CollaborativeMessage copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? content,
    DateTime? timestamp,
    MessageType? type,
    Map<String, dynamic>? metadata,
  }) {
    return CollaborativeMessage(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'type': type.toString().split('.').last,
      'metadata': metadata,
    };
  }

  factory CollaborativeMessage.fromJson(Map<String, dynamic> json) {
    return CollaborativeMessage(
      id: json['id'],
      senderId: json['senderId'],
      senderName: json['senderName'],
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
      type: MessageType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => MessageType.text,
      ),
      metadata: json['metadata'],
    );
  }
}

/// Enum for message types in a collaborative session
enum MessageType {
  text,
  image,
  file,
  problem,
  solution,
  drawing,
  system,
}

/// Provider for managing collaborative learning sessions
class CollaborativeProvider with ChangeNotifier {
  List<CollaborativeSession> _sessions = [];
  CollaborativeSession? _currentSession;
  CollaborativeUser? _currentUser;
  final Uuid _uuid = const Uuid();
  Timer? _heartbeatTimer;

  List<CollaborativeSession> get sessions => _sessions;
  List<CollaborativeSession> get availableSessions => _sessions.where((s) => s.isActive).toList();
  CollaborativeSession? get currentSession => _currentSession;
  CollaborativeUser? get currentUser => _currentUser;
  bool get isInSession => _currentSession != null;

  CollaborativeProvider() {
    _loadSessions();
  }

  /// Load saved sessions from SharedPreferences
  Future<void> _loadSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionsJson = prefs.getStringList('collaborative_sessions');
      if (sessionsJson != null) {
        _sessions = sessionsJson
            .map((json) => CollaborativeSession.fromJson(jsonDecode(json)))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading collaborative sessions: $e');
    }
  }

  /// Save sessions to SharedPreferences
  Future<void> _saveSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionsJson = _sessions
          .map((session) => jsonEncode(session.toJson()))
          .toList();
      await prefs.setStringList('collaborative_sessions', sessionsJson);
    } catch (e) {
      debugPrint('Error saving collaborative sessions: $e');
    }
  }

  /// Set the current user for collaborative sessions
  void setCurrentUser(String userId, String userName) {
    _currentUser = CollaborativeUser(
      id: userId,
      name: userName,
      lastActive: DateTime.now(),
    );
    notifyListeners();
  }

  /// Fetch available sessions from the server or local storage
  Future<void> fetchAvailableSessions() async {
    // In a real app, this would make an API call to get sessions
    // For now, we'll create some mock data
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    
    _sessions = [
      CollaborativeSession(
        id: '123456',
        name: 'Math Study Group',
        subject: 'Math',
        creatorId: 'user1',
        creatorName: 'John Doe',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        participants: [
          CollaborativeUser(
            id: 'user1',
            name: 'John Doe',
            isOnline: true,
            lastActive: DateTime.now(),
          ),
          CollaborativeUser(
            id: 'user2',
            name: 'Jane Smith',
            isOnline: false,
            lastActive: DateTime.now().subtract(const Duration(minutes: 30)),
          ),
        ],
        messages: [],
      ),
      CollaborativeSession(
        id: '789012',
        name: 'Language Practice',
        subject: 'Language',
        creatorId: 'user3',
        creatorName: 'Alice Johnson',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        participants: [
          CollaborativeUser(
            id: 'user3',
            name: 'Alice Johnson',
            isOnline: true,
            lastActive: DateTime.now(),
          ),
          CollaborativeUser(
            id: 'user4',
            name: 'Bob Williams',
            isOnline: true,
            lastActive: DateTime.now(),
          ),
          CollaborativeUser(
            id: 'user5',
            name: 'Charlie Brown',
            isOnline: false,
            lastActive: DateTime.now().subtract(const Duration(hours: 1)),
          ),
        ],
        messages: [],
      ),
    ];
    
    notifyListeners();
  }

  /// Create a new collaborative session
  Future<String> createSession(String name, String subject) async {
    if (_currentUser == null) {
      throw Exception('User not authenticated');
    }
    
    // In a real app, this would make an API call to create a session
    // For now, we'll create a local session
    final sessionId = _uuid.v4();
    
    final newSession = CollaborativeSession(
      id: sessionId,
      name: name,
      subject: subject,
      creatorId: _currentUser!.id,
      creatorName: _currentUser!.name,
      createdAt: DateTime.now(),
      participants: [_currentUser!],
      messages: [
        CollaborativeMessage(
          id: _uuid.v4(),
          senderId: 'system',
          senderName: 'System',
          content: 'Session created by ${_currentUser!.name}',
          timestamp: DateTime.now(),
          type: MessageType.system,
        ),
      ],
    );
    
    _sessions.add(newSession);
    _currentSession = newSession;
    
    // Start heartbeat to keep user online
    _startHeartbeat();
    
    notifyListeners();
    return sessionId;
  }

  /// Join an existing collaborative session
  Future<void> joinSession(String sessionId) async {
    if (_currentUser == null) {
      throw Exception('User not authenticated');
    }

    final session = _sessions.firstWhere(
      (s) => s.id == sessionId,
      orElse: () => throw Exception('Session not found'),
    );

    if (!session.isActive) {
      throw Exception('Session is no longer active');
    }

    session.participants.add(_currentUser!);
    _currentSession = session;
    
    // Add system message for user joining
    session.messages.add(
      CollaborativeMessage(
        id: _uuid.v4(),
        senderId: 'system',
        senderName: 'System',
        content: '${_currentUser!.name} joined the session',
        timestamp: DateTime.now(),
        type: MessageType.system,
      ),
    );

    _startHeartbeat();
    await _saveSessions();
    notifyListeners();
  }

  /// Leave the current collaborative session
  Future<void> leaveSession() async {
    if (_currentSession == null || _currentUser == null) return;

    _currentSession!.participants.removeWhere((p) => p.id == _currentUser!.id);
    
    // Add system message for user leaving
    _currentSession!.messages.add(
      CollaborativeMessage(
        id: _uuid.v4(),
        senderId: 'system',
        senderName: 'System',
        content: '${_currentUser!.name} left the session',
        timestamp: DateTime.now(),
        type: MessageType.system,
      ),
    );

    if (_currentSession!.participants.isEmpty) {
      _currentSession!.isActive = false;
    }

    _currentSession = null;
    _stopHeartbeat();
    await _saveSessions();
    notifyListeners();
  }

  /// Send a message in the current session
  Future<void> sendMessage(String content, {MessageType type = MessageType.text}) async {
    if (_currentSession == null || _currentUser == null) {
      throw Exception('Not in a session');
    }

    final message = CollaborativeMessage(
      id: _uuid.v4(),
      senderId: _currentUser!.id,
      senderName: _currentUser!.name,
      content: content,
      timestamp: DateTime.now(),
      type: type,
    );

    _currentSession!.messages.add(message);
    await _saveSessions();
    notifyListeners();
  }

  /// Send a problem in the current session
  Future<void> sendProblem(String problem, String subject) async {
    if (_currentUser == null || _currentSession == null) {
      throw Exception('Not in a session');
    }
    
    final newMessage = CollaborativeMessage(
      id: _uuid.v4(),
      senderId: _currentUser!.id,
      senderName: _currentUser!.name,
      content: problem,
      timestamp: DateTime.now(),
      type: MessageType.problem,
      metadata: {
        'subject': subject,
      },
    );
    
    // Add message to session
    final updatedMessages = [..._currentSession!.messages, newMessage];
    
    // Update session
    final updatedSession = _currentSession!.copyWith(
      messages: updatedMessages,
    );
    
    // Update sessions list
    final updatedSessions = [..._sessions];
    final index = updatedSessions.indexWhere((s) => s.id == _currentSession!.id);
    if (index != -1) {
      updatedSessions[index] = updatedSession;
    }
    
    _sessions = updatedSessions;
    _currentSession = updatedSession;
    
    notifyListeners();
  }

  /// Send a solution to a problem in the current session
  Future<void> sendSolution(String solution, String problemId) async {
    if (_currentUser == null || _currentSession == null) {
      throw Exception('Not in a session');
    }
    
    final newMessage = CollaborativeMessage(
      id: _uuid.v4(),
      senderId: _currentUser!.id,
      senderName: _currentUser!.name,
      content: solution,
      timestamp: DateTime.now(),
      type: MessageType.solution,
      metadata: {
        'problemId': problemId,
      },
    );
    
    // Add message to session
    final updatedMessages = [..._currentSession!.messages, newMessage];
    
    // Update session
    final updatedSession = _currentSession!.copyWith(
      messages: updatedMessages,
    );
    
    // Update sessions list
    final updatedSessions = [..._sessions];
    final index = updatedSessions.indexWhere((s) => s.id == _currentSession!.id);
    if (index != -1) {
      updatedSessions[index] = updatedSession;
    }
    
    _sessions = updatedSessions;
    _currentSession = updatedSession;
    
    notifyListeners();
  }

  /// Start the heartbeat timer to keep user online
  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (_currentUser != null) {
        _currentUser!.lastActive = DateTime.now();
        notifyListeners();
      }
    });
  }

  /// Stop the heartbeat timer
  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  @override
  void dispose() {
    _stopHeartbeat();
    super.dispose();
  }
} 