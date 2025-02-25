import 'dart:async';
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
        // TODO: Implement proper JSON parsing
        // This is a placeholder for actual implementation
        _sessions = [];
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
      // TODO: Implement proper JSON serialization
      // This is a placeholder for actual implementation
      await prefs.setStringList('collaborative_sessions', []);
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
  Future<bool> joinSession(String sessionId) async {
    if (_currentUser == null) {
      throw Exception('User not authenticated');
    }
    
    // Find the session
    final sessionIndex = _sessions.indexWhere((s) => s.id == sessionId);
    
    if (sessionIndex == -1) {
      // In a real app, this would make an API call to find the session
      // For now, we'll create a mock session if it doesn't exist locally
      final mockSession = CollaborativeSession(
        id: sessionId,
        name: 'Session $sessionId',
        subject: 'Math',
        creatorId: 'unknown',
        creatorName: 'Unknown User',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        participants: [],
        messages: [
          CollaborativeMessage(
            id: _uuid.v4(),
            senderId: 'system',
            senderName: 'System',
            content: 'Session created',
            timestamp: DateTime.now().subtract(const Duration(hours: 1)),
            type: MessageType.system,
          ),
        ],
      );
      
      _sessions.add(mockSession);
      _currentSession = mockSession;
    } else {
      _currentSession = _sessions[sessionIndex];
    }
    
    // Check if user is already a participant
    final isParticipant = _currentSession!.participants.any((p) => p.id == _currentUser!.id);
    
    if (!isParticipant) {
      // Add user to participants
      final updatedParticipants = [..._currentSession!.participants, _currentUser!];
      
      // Add system message
      final updatedMessages = [..._currentSession!.messages];
      updatedMessages.add(
        CollaborativeMessage(
          id: _uuid.v4(),
          senderId: 'system',
          senderName: 'System',
          content: '${_currentUser!.name} joined the session',
          timestamp: DateTime.now(),
          type: MessageType.system,
        ),
      );
      
      // Update session
      final updatedSession = _currentSession!.copyWith(
        participants: updatedParticipants,
        messages: updatedMessages,
      );
      
      // Update sessions list
      final updatedSessions = [..._sessions];
      final index = updatedSessions.indexWhere((s) => s.id == sessionId);
      if (index != -1) {
        updatedSessions[index] = updatedSession;
      }
      
      _sessions = updatedSessions;
      _currentSession = updatedSession;
    } else {
      // Update user's online status
      final updatedParticipants = _currentSession!.participants.map((p) {
        if (p.id == _currentUser!.id) {
          return p.copyWith(isOnline: true, lastActive: DateTime.now());
        }
        return p;
      }).toList();
      
      // Update session
      final updatedSession = _currentSession!.copyWith(
        participants: updatedParticipants,
      );
      
      // Update sessions list
      final updatedSessions = [..._sessions];
      final index = updatedSessions.indexWhere((s) => s.id == sessionId);
      if (index != -1) {
        updatedSessions[index] = updatedSession;
      }
      
      _sessions = updatedSessions;
      _currentSession = updatedSession;
    }
    
    // Start heartbeat to keep user online
    _startHeartbeat();
    
    notifyListeners();
    return true;
  }

  /// Leave the current collaborative session
  Future<void> leaveSession() async {
    if (_currentUser == null || _currentSession == null) {
      return;
    }
    
    // Update user's online status
    final updatedParticipants = _currentSession!.participants.map((p) {
      if (p.id == _currentUser!.id) {
        return p.copyWith(isOnline: false, lastActive: DateTime.now());
      }
      return p;
    }).toList();
    
    // Add system message
    final updatedMessages = [..._currentSession!.messages];
    updatedMessages.add(
      CollaborativeMessage(
        id: _uuid.v4(),
        senderId: 'system',
        senderName: 'System',
        content: '${_currentUser!.name} left the session',
        timestamp: DateTime.now(),
        type: MessageType.system,
      ),
    );
    
    // Update session
    final updatedSession = _currentSession!.copyWith(
      participants: updatedParticipants,
      messages: updatedMessages,
    );
    
    // Update sessions list
    final updatedSessions = [..._sessions];
    final index = updatedSessions.indexWhere((s) => s.id == _currentSession!.id);
    if (index != -1) {
      updatedSessions[index] = updatedSession;
    }
    
    _sessions = updatedSessions;
    _currentSession = null;
    
    // Stop heartbeat
    _stopHeartbeat();
    
    notifyListeners();
  }

  /// Send a message in the current session
  Future<void> sendMessage(String content) async {
    if (_currentUser == null || _currentSession == null) {
      throw Exception('Not in a session');
    }
    
    final newMessage = CollaborativeMessage(
      id: _uuid.v4(),
      senderId: _currentUser!.id,
      senderName: _currentUser!.name,
      content: content,
      timestamp: DateTime.now(),
      type: MessageType.text,
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

  /// Start heartbeat timer to keep user online
  void _startHeartbeat() {
    _stopHeartbeat(); // Stop any existing heartbeat
    
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (_currentUser != null && _currentSession != null) {
        // Update user's last active time
        final updatedParticipants = _currentSession!.participants.map((p) {
          if (p.id == _currentUser!.id) {
            return p.copyWith(isOnline: true, lastActive: DateTime.now());
          }
          return p;
        }).toList();
        
        // Update session
        final updatedSession = _currentSession!.copyWith(
          participants: updatedParticipants,
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
    });
  }

  /// Stop heartbeat timer
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