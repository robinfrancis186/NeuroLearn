import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'subject_screen.dart';
import '../theme/app_colors.dart';

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

enum GameDifficulty { easy, medium, hard }
enum GameTheme { emoji, shapes, colors, animals, food }

class _MemoryScreenState extends SubjectScreenState<MemoryScreen> with TickerProviderStateMixin {
  // Game configuration
  GameDifficulty _difficulty = GameDifficulty.easy;
  GameTheme _theme = GameTheme.emoji;
  
  // Game state
  List<dynamic> _cards = [];
  List<bool> _flipped = [];
  List<bool> _matched = [];
  int _moves = 0;
  int _matches = 0;
  int? _firstFlippedIndex;
  bool _canFlip = true;
  
  // Timer and scoring
  Timer? _gameTimer;
  int _secondsElapsed = 0;
  int _score = 0;
  bool _gameCompleted = false;
  
  // Animation controllers
  late AnimationController _flipController;
  
  // Statistics
  int _gamesPlayed = 0;
  int _gamesWon = 0;
  int _bestScore = 0;
  int _fastestTime = 0;
  
  // Theme content
  final Map<GameTheme, List<dynamic>> _themeContent = {
    GameTheme.emoji: ['🐶', '🐱', '🐭', '🐹', '🐰', '🦊', '🐻', '🐼', '🐮', '🐵', '🐸', '🐔'],
    GameTheme.shapes: [
      Icons.circle, Icons.square, Icons.change_history, Icons.hexagon, 
      Icons.pentagon, Icons.star, Icons.heart_broken, Icons.diamond,
      Icons.rectangle, Icons.architecture, Icons.crop_square, Icons.crop_din
    ],
    GameTheme.colors: [
      Colors.red, Colors.blue, Colors.green, Colors.yellow, 
      Colors.orange, Colors.purple, Colors.pink, Colors.teal,
      Colors.indigo, Colors.amber, Colors.cyan, Colors.brown
    ],
    GameTheme.animals: ['🦁', '🐯', '🐘', '🦒', '🦓', '🦍', '🦛', '🐊', '🐢', '🦜', '🦢', '🦩'],
    GameTheme.food: ['🍎', '🍌', '🍇', '🍓', '🍕', '🍔', '🍦', '🍩', '🍪', '🍫', '🍰', '🥞'],
  };

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _loadStatistics();
    _initializeGame();
  }

  Future<void> _loadStatistics() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _gamesPlayed = prefs.getInt('memory_games_played') ?? 0;
      _gamesWon = prefs.getInt('memory_games_won') ?? 0;
      _bestScore = prefs.getInt('memory_best_score') ?? 0;
      _fastestTime = prefs.getInt('memory_fastest_time') ?? 0;
      _difficulty = GameDifficulty.values[prefs.getInt('memory_difficulty') ?? 0];
      _theme = GameTheme.values[prefs.getInt('memory_theme') ?? 0];
    });
  }

  Future<void> _saveStatistics() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('memory_games_played', _gamesPlayed);
    await prefs.setInt('memory_games_won', _gamesWon);
    await prefs.setInt('memory_best_score', _bestScore);
    await prefs.setInt('memory_fastest_time', _fastestTime);
    await prefs.setInt('memory_difficulty', _difficulty.index);
    await prefs.setInt('memory_theme', _theme.index);
  }

  void _initializeGame() {
    // Stop any existing timer
    _gameTimer?.cancel();
    
    // Reset game state
    _moves = 0;
    _matches = 0;
    _secondsElapsed = 0;
    _score = 0;
    _gameCompleted = false;
    _firstFlippedIndex = null;
    _canFlip = true;
    
    // Get cards based on difficulty
    int pairCount;
    switch (_difficulty) {
      case GameDifficulty.easy:
        pairCount = 6;
        break;
      case GameDifficulty.medium:
        pairCount = 8;
        break;
      case GameDifficulty.hard:
        pairCount = 12;
        break;
    }
    
    // Get theme content
    List<dynamic> themeItems = _themeContent[_theme]!.sublist(0, pairCount);
    
    // Create pairs
    _cards = [...themeItems, ...themeItems];
    _flipped = List.filled(_cards.length, false);
    _matched = List.filled(_cards.length, false);
    
    // Shuffle cards
    final random = math.Random();
    for (int i = _cards.length - 1; i > 0; i--) {
      int j = random.nextInt(i + 1);
      var temp = _cards[i];
      _cards[i] = _cards[j];
      _cards[j] = temp;
    }
    
    // Start timer
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _secondsElapsed++;
      });
    });
    
    setState(() {});
    speak("Match the pairs of cards. Tap a card to flip it.");
  }

  void _flipCard(int index) {
    if (!_canFlip || _flipped[index] || _matched[index] || _gameCompleted) return;

    _flipController.reset();
    _flipController.forward();

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

          if (_matches == _cards.length ~/ 2) {
            _gameCompleted = true;
            _gameTimer?.cancel();
            _calculateScore();
            _updateStatistics();
            speak("Congratulations! You've completed the memory game!");
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

  void _calculateScore() {
    // Base score depends on difficulty
    int baseScore;
    switch (_difficulty) {
      case GameDifficulty.easy:
        baseScore = 100;
        break;
      case GameDifficulty.medium:
        baseScore = 200;
        break;
      case GameDifficulty.hard:
        baseScore = 300;
        break;
    }
    
    // Time bonus: faster completion = higher score
    int timeBonus = 0;
    if (_secondsElapsed < 60) {
      timeBonus = (60 - _secondsElapsed) * 5;
    }
    
    // Move efficiency bonus: fewer moves = higher score
    int moveBonus = 0;
    int optimalMoves = _cards.length ~/ 2 * 2; // Optimal is 2 moves per pair
    if (_moves <= optimalMoves * 1.5) {
      moveBonus = (optimalMoves * 2 - _moves) * 10;
    }
    
    _score = baseScore + timeBonus + moveBonus;
    setState(() {});
  }

  void _updateStatistics() {
    _gamesPlayed++;
    _gamesWon++;
    
    if (_score > _bestScore) {
      _bestScore = _score;
    }
    
    if (_fastestTime == 0 || _secondsElapsed < _fastestTime) {
      _fastestTime = _secondsElapsed;
    }
    
    _saveStatistics();
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _flipController.dispose();
    super.dispose();
  }

  @override
  String getWelcomeMessage() {
    return "Let's exercise your memory!";
  }

  @override
  Widget buildSubjectContent() {
    return Column(
      children: [
        _buildGameHeader(),
        _buildDifficultySelector(),
        _buildThemeSelector(),
        Expanded(
          child: _buildGameGrid(),
        ),
        if (_gameCompleted) _buildGameCompletedCard(),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _initializeGame,
                  icon: const Icon(Icons.refresh),
                  label: const Text('New Game'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.color.withAlpha(51),
                    foregroundColor: widget.color,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _showStatistics,
                  icon: const Icon(Icons.bar_chart),
                  label: const Text('Statistics'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary.withAlpha(51),
                    foregroundColor: AppColors.secondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGameHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Moves: $_moves',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                'Matches: $_matches/${_cards.length ~/ 2}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Time: ${_formatTime(_secondsElapsed)}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (_gameCompleted)
                Text(
                  'Score: $_score',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: widget.color,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultySelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          const Text('Difficulty:'),
          const SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: GameDifficulty.values.map((difficulty) {
                  bool isSelected = difficulty == _difficulty;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(_getDifficultyLabel(difficulty)),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _difficulty = difficulty;
                            _initializeGame();
                          });
                        }
                      },
                      backgroundColor: widget.color.withAlpha(30),
                      selectedColor: widget.color,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : widget.color,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          const Text('Theme:'),
          const SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: GameTheme.values.map((theme) {
                  bool isSelected = theme == _theme;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(_getThemeLabel(theme)),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _theme = theme;
                            _initializeGame();
                          });
                        }
                      },
                      backgroundColor: widget.color.withAlpha(30),
                      selectedColor: widget.color,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : widget.color,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _difficulty == GameDifficulty.hard ? 4 : 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _cards.length,
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: _flipController,
          builder: (context, child) {
            final flipValue = _flipped[index] ? 
                _flipController.value : 
                (1 - _flipController.value);
            
            return GestureDetector(
              onTap: () => _flipCard(index),
              child: Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(flipValue * math.pi),
                alignment: Alignment.center,
                child: flipValue < 0.5 ?
                  // Back of card
                  Card(
                    elevation: 4,
                    color: widget.color.withAlpha(51),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: widget.color.withAlpha(100),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '?',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: widget.color.withAlpha(128),
                        ),
                      ),
                    ),
                  ) :
                  // Front of card
                  Card(
                    elevation: 4,
                    color: _matched[index]
                        ? Colors.green.withAlpha(51)
                        : widget.color.withAlpha(26),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: _matched[index]
                            ? Colors.green
                            : widget.color,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: _buildCardContent(index),
                    ),
                  ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCardContent(int index) {
    if (_theme == GameTheme.emoji || _theme == GameTheme.animals || _theme == GameTheme.food) {
      return Text(
        _cards[index],
        style: TextStyle(
          fontSize: 32,
          color: _matched[index] ? Colors.green : widget.color,
        ),
      );
    } else if (_theme == GameTheme.shapes) {
      return Icon(
        _cards[index],
        size: 40,
        color: _matched[index] ? Colors.green : widget.color,
      );
    } else if (_theme == GameTheme.colors) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _cards[index],
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: 2,
          ),
        ),
      );
    }
    return const SizedBox();
  }

  Widget _buildGameCompletedCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withAlpha(30),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green),
      ),
      child: Column(
        children: [
          const Text(
            '🎉 Game Completed! 🎉',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Score: $_score',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Time: ${_formatTime(_secondsElapsed)}',
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            'Moves: $_moves',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  void _showStatistics() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Your Statistics'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatItem('Games Played', _gamesPlayed.toString()),
            _buildStatItem('Games Won', _gamesWon.toString()),
            _buildStatItem('Best Score', _bestScore.toString()),
            _buildStatItem('Fastest Time', _fastestTime > 0 ? _formatTime(_fastestTime) : 'N/A'),
            _buildStatItem('Win Rate', _gamesPlayed > 0 ? '${(_gamesWon / _gamesPlayed * 100).toStringAsFixed(1)}%' : 'N/A'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _gamesPlayed = 0;
                _gamesWon = 0;
                _bestScore = 0;
                _fastestTime = 0;
              });
              _saveStatistics();
              Navigator.of(context).pop();
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(value),
        ],
      ),
    );
  }

  String _getDifficultyLabel(GameDifficulty difficulty) {
    switch (difficulty) {
      case GameDifficulty.easy:
        return 'Easy';
      case GameDifficulty.medium:
        return 'Medium';
      case GameDifficulty.hard:
        return 'Hard';
    }
  }

  String _getThemeLabel(GameTheme theme) {
    switch (theme) {
      case GameTheme.emoji:
        return 'Emoji';
      case GameTheme.shapes:
        return 'Shapes';
      case GameTheme.colors:
        return 'Colors';
      case GameTheme.animals:
        return 'Animals';
      case GameTheme.food:
        return 'Food';
    }
  }
} 