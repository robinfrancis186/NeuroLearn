import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import '../constants/app_constants.dart';

class AppUtils {
  // Date formatting
  static String formatDate(DateTime date, {String? format}) {
    return DateFormat(format ?? AppConstants.dateFormatDisplay).format(date);
  }
  
  // Time formatting
  static String formatTime(DateTime time) {
    return DateFormat(AppConstants.timeFormatDisplay).format(time);
  }
  
  // File size formatting
  static String formatFileSize(int bytes) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(2)} ${suffixes[i]}';
  }
  
  // Get temporary directory path
  static Future<String> getTempPath() async {
    final directory = await getTemporaryDirectory();
    return directory.path;
  }
  
  // Get application documents directory path
  static Future<String> getAppDocPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }
  
  // Create directory if not exists
  static Future<Directory> createDirIfNotExists(String path) async {
    final dir = Directory(path);
    if (!(await dir.exists())) {
      await dir.create(recursive: true);
    }
    return dir;
  }
  
  // Delete directory and contents
  static Future<void> deleteDirectory(String path) async {
    final dir = Directory(path);
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }
  
  // Show snackbar
  static void showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: duration,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  // Show loading dialog
  static void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
  
  // Hide loading dialog
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }
  
  // Show confirmation dialog
  static Future<bool> showConfirmationDialog(
    BuildContext context,
    String title,
    String message,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
  
  // Validate email
  static bool isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+').hasMatch(email);
  }
  
  // Validate password strength
  static bool isStrongPassword(String password) {
    return password.length >= 8 &&
           RegExp(r'[A-Z]').hasMatch(password) &&
           RegExp(r'[a-z]').hasMatch(password) &&
           RegExp(r'[0-9]').hasMatch(password) &&
           RegExp(r'[!@#\$&*~]').hasMatch(password);
  }
  
  // Generate random string
  static String generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }
  
  // Check if device is online
  static Future<bool> isOnline() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }
  
  // Debounce function
  static Timer? _debounceTimer;
  static void debounce(VoidCallback action, {Duration? duration}) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(
      duration ?? const Duration(milliseconds: 500),
      action,
    );
  }
  
  // Throttle function
  static DateTime? _lastRun;
  static void throttle(VoidCallback action, {Duration? duration}) {
    final now = DateTime.now();
    if (_lastRun == null ||
        now.difference(_lastRun!) > (duration ?? const Duration(seconds: 1))) {
      action();
      _lastRun = now;
    }
  }

  static String formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  static String getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} years ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'just now';
    }
  }

  static Color getSubjectColor(String subject) {
    switch (subject.toLowerCase()) {
      case 'math':
        return Colors.blue;
      case 'language':
        return Colors.green;
      case 'memory':
        return Colors.purple;
      case 'life_skills':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
} 