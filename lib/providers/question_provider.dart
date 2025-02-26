import 'dart:io';
import 'package:flutter/material.dart';

class QuestionProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<Map<String, dynamic>> submitQuestion({
    required String question,
    File? image,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // TODO: Implement actual API call
      // For now, return mock response
      await Future.delayed(const Duration(seconds: 2));
      
      return {
        'question': question,
        'answer': 'This is a mock answer to your question.',
        'imageUrl': image?.path,
      };
    } catch (e) {
      _error = e.toString();
      throw e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
} 