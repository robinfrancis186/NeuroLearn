import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/performance_provider.dart';

/// A widget that generates math word problems using isolates for better performance
class WordProblemGenerator extends StatefulWidget {
  final String difficulty;
  final String operationType;

  const WordProblemGenerator({
    Key? key,
    required this.difficulty,
    required this.operationType,
  }) : super(key: key);

  @override
  State<WordProblemGenerator> createState() => _WordProblemGeneratorState();
}

class _WordProblemGeneratorState extends State<WordProblemGenerator> {
  bool _isLoading = true;
  String _problem = '';
  List<String> _solutionSteps = [];

  @override
  void initState() {
    super.initState();
    _generateProblem();
  }

  @override
  void didUpdateWidget(WordProblemGenerator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.difficulty != widget.difficulty || 
        oldWidget.operationType != widget.operationType) {
      _generateProblem();
    }
  }

  Future<void> _generateProblem() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final performanceProvider = Provider.of<PerformanceProvider>(context, listen: false);
      
      // Run the computation in an isolate
      final result = await performanceProvider.runComputation(
        'generateWordProblem',
        {
          'difficulty': widget.difficulty,
          'operationType': widget.operationType,
        },
      );

      if (mounted) {
        setState(() {
          _problem = result['problem'] as String;
          _solutionSteps = List<String>.from(result['solution']);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _problem = 'Error generating problem: $e';
          _solutionSteps = [];
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          elevation: 4,
          margin: const EdgeInsets.all(8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              _problem,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Solution Steps:',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        ...List.generate(
          _solutionSteps.length,
          (index) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${index + 1}. '),
                Expanded(
                  child: Text(_solutionSteps[index]),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _generateProblem,
          child: const Text('Generate New Problem'),
        ),
      ],
    );
  }
} 