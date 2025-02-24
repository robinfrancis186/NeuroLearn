import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'subject_screen.dart';

class MathScreen extends SubjectScreen {
  const MathScreen({super.key})
      : super(
          subject: 'Mathematics',
          color: Colors.blue,
          icon: Icons.calculate,
        );

  @override
  State<MathScreen> createState() => _MathScreenState();
}

class _MathScreenState extends SubjectScreenState<MathScreen> {
  int firstNumber = 0;
  int secondNumber = 0;
  String operation = '+';
  List<int> options = [];
  int? selectedAnswer;
  bool isCorrect = false;

  @override
  void initState() {
    super.initState();
    generateNewProblem();
  }

  void generateNewProblem() {
    final random = math.Random();
    firstNumber = random.nextInt(10) + 1;
    secondNumber = random.nextInt(10) + 1;
    operation = ['+', '-', '×'][random.nextInt(3)];

    int correctAnswer;
    switch (operation) {
      case '+':
        correctAnswer = firstNumber + secondNumber;
        break;
      case '-':
        correctAnswer = firstNumber - secondNumber;
        break;
      case '×':
        correctAnswer = firstNumber * secondNumber;
        break;
      default:
        correctAnswer = 0;
    }

    options = [
      correctAnswer,
      correctAnswer + random.nextInt(5) + 1,
      correctAnswer - random.nextInt(5) - 1,
      correctAnswer + random.nextInt(10) - 5,
    ]..shuffle();

    selectedAnswer = null;
    isCorrect = false;
    setState(() {});
  }

  void checkAnswer(int answer) {
    int correctAnswer;
    switch (operation) {
      case '+':
        correctAnswer = firstNumber + secondNumber;
        break;
      case '-':
        correctAnswer = firstNumber - secondNumber;
        break;
      case '×':
        correctAnswer = firstNumber * secondNumber;
        break;
      default:
        correctAnswer = 0;
    }

    setState(() {
      selectedAnswer = answer;
      isCorrect = answer == correctAnswer;
    });

    if (isCorrect) {
      speak("Great job! That's correct!");
      Future.delayed(const Duration(seconds: 2), generateNewProblem);
    } else {
      speak("Try again! You can do it!");
    }
  }

  @override
  String getWelcomeMessage() {
    return "Let's practice some math problems!";
  }

  @override
  Widget buildSubjectContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  '$firstNumber $operation $secondNumber = ?',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  children: options.map((option) {
                    bool isSelected = selectedAnswer == option;
                    bool showResult = isSelected && selectedAnswer != null;
                    Color buttonColor = showResult
                        ? (isCorrect ? Colors.green : Colors.red)
                        : widget.color;

                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonColor.withOpacity(0.2),
                        foregroundColor: buttonColor,
                        padding: const EdgeInsets.all(20),
                      ),
                      onPressed: () => checkAnswer(option),
                      child: Text(
                        option.toString(),
                        style: const TextStyle(fontSize: 24),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: generateNewProblem,
          icon: const Icon(Icons.refresh),
          label: const Text('New Problem'),
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.color.withOpacity(0.2),
            foregroundColor: widget.color,
          ),
        ),
      ],
    );
  }
} 