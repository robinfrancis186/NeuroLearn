import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/performance_provider.dart';

/// A widget that displays animations with frame budgeting for better performance
class OptimizedAnimation extends StatefulWidget {
  final int itemCount;
  final Widget Function(BuildContext, int, Animation<double>) itemBuilder;
  final Duration duration;
  final Curve curve;

  const OptimizedAnimation({
    Key? key,
    required this.itemCount,
    required this.itemBuilder,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
  }) : super(key: key);

  @override
  State<OptimizedAnimation> createState() => _OptimizedAnimationState();
}

class _OptimizedAnimationState extends State<OptimizedAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;
  final List<int> _visibleItems = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    
    _setupAnimations();
    _startAnimations();
  }

  @override
  void didUpdateWidget(OptimizedAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.itemCount != widget.itemCount || 
        oldWidget.duration != widget.duration ||
        oldWidget.curve != widget.curve) {
      _controller.reset();
      _setupAnimations();
      _startAnimations();
    }
  }

  void _setupAnimations() {
    _animations = List.generate(
      widget.itemCount,
      (index) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            index / widget.itemCount * 0.8,
            (index + 1) / widget.itemCount,
            curve: widget.curve,
          ),
        ),
      ),
    );
    
    _visibleItems.clear();
  }

  void _startAnimations() {
    final performanceProvider = Provider.of<PerformanceProvider>(context, listen: false);
    
    // Add animation callback to be executed within frame budget
    performanceProvider.addAnimationCallback(_animateNextItem);
    
    // Start the animation controller
    _controller.forward();
  }

  void _animateNextItem() {
    if (_visibleItems.length < widget.itemCount) {
      setState(() {
        _visibleItems.add(_visibleItems.length);
      });
    } else {
      // All items are visible, remove the callback
      final performanceProvider = Provider.of<PerformanceProvider>(context, listen: false);
      performanceProvider.removeAnimationCallback(_animateNextItem);
    }
  }

  @override
  void dispose() {
    // Remove animation callback when widget is disposed
    final performanceProvider = Provider.of<PerformanceProvider>(context, listen: false);
    performanceProvider.removeAnimationCallback(_animateNextItem);
    
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _visibleItems.length,
      itemBuilder: (context, index) {
        final itemIndex = _visibleItems[index];
        return widget.itemBuilder(context, itemIndex, _animations[itemIndex]);
      },
    );
  }
} 