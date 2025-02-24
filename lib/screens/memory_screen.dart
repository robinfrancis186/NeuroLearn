import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'subject_screen.dart';

class MemoryScreen extends SubjectScreen {
  const MemoryScreen({super.key})
      : super(
          subject: 'Memory',
          color: Colors.purple,
          icon: Icons.psychology,
        );

  @override
  State<MemoryScreen> createState() => _MemoryScreenState();
}

class _MemoryScreenState extends SubjectScreenState<MemoryScreen> {
  List<String> _emojis = ['🐶', '🐱', '🐭', '🐰', '🦊', '🐻', '🐼', '🐨'];
  List<String> _cards = [];
  List<bool> _flipped = [];
  List<bool> _matched = [];
  int? _firstFlippedIndex;
  bool _canFlip = true;
  int _moves = 0;
  int _matches = 0;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    // Create pairs of emojis
    _cards = [..._emojis, ..._emojis];
    _flipped = List.filled(_cards.length, false);
    _matched = List.filled(_cards.length, false);
    _firstFlippedIndex = null;
    _moves = 0;
    _matches = 0;
    _canFlip = true;

    // Shuffle cards
    final random = math.Random();
    for (int i = _cards.length - 1; i > 0; i--) {
      int j = random.nextInt(i + 1);
      String temp = _cards[i];
      _cards[i] = _cards[j];
      _cards[j] = temp;
    }

    setState(() {});
    speak("Match the pairs of cards. Tap a card to flip it.");
  }

  void _flipCard(int index) {
    if (!_canFlip || _flipped[index] || _matched[index]) return;

    setState(() {
      _flipped[index] = true;

      if (_firstFlippedIndex == null) {
        _firstFlippedIndex = index;
      } else {
        _moves++;
        if (_cards[_firstFlippedIndex!] == _cards[index]) {
          // Match found
          _matched[_firstFlippedIndex!] = true;
          _matched[index] = true;
          _firstFlippedIndex = null;
          _matches++;

          if (_matches == _emojis.length) {
            speak("Congratulations! You've completed the memory game!");
            Future.delayed(
              const Duration(seconds: 3),
              _initializeGame,
            );
          } else {
            speak("Great match!");
          }
        } else {
          // No match
          _canFlip = false;
          Future.delayed(const Duration(milliseconds: 1000), () {
            setState(() {
              _flipped[_firstFlippedIndex!] = false;
              _flipped[index] = false;
              _firstFlippedIndex = null;
              _canFlip = true;
            });
          });
        }
      }
    });
  }

  @override
  String getWelcomeMessage() {
    return "Let's exercise your memory!";
  }

  @override
  Widget buildSubjectContent() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Moves: $_moves',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(
                'Matches: $_matches',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: _cards.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _flipCard(index),
                child: Card(
                  color: _matched[index]
                      ? Colors.green.withOpacity(0.2)
                      : _flipped[index]
                          ? widget.color.withOpacity(0.1)
                          : widget.color.withOpacity(0.2),
                  child: Center(
                    child: Text(
                      _flipped[index] || _matched[index] ? _cards[index] : '?',
                      style: TextStyle(
                        fontSize: 32,
                        color: _matched[index]
                            ? Colors.green
                            : _flipped[index]
                                ? widget.color
                                : widget.color.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: _initializeGame,
            icon: const Icon(Icons.refresh),
            label: const Text('New Game'),
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.color.withOpacity(0.2),
              foregroundColor: widget.color,
            ),
          ),
        ),
      ],
    );
  }
} 