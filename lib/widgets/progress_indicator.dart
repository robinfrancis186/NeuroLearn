import 'package:flutter/material.dart';
import 'dart:math' as math;

class CustomProgressIndicator extends StatelessWidget {
  final double progress;
  final Color color;
  final double size;
  final double strokeWidth;

  const CustomProgressIndicator({
    Key? key,
    required this.progress,
    required this.color,
    this.size = 50,
    this.strokeWidth = 6.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: Stack(
        children: [
          // Background circle
          SizedBox(
            height: size,
            width: size,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: strokeWidth,
              backgroundColor: color.withAlpha(30),
              valueColor: AlwaysStoppedAnimation<Color>(Colors.transparent),
            ),
          ),
          // Progress arc with gradient
          ShaderMask(
            shaderCallback: (Rect bounds) {
              return SweepGradient(
                startAngle: 0.0,
                endAngle: 2 * math.pi,
                colors: [
                  color.withAlpha(150),
                  color,
                ],
                stops: const [0.0, 1.0],
                transform: const GradientRotation(-math.pi / 2),
              ).createShader(bounds);
            },
            child: SizedBox(
              height: size,
              width: size,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: strokeWidth,
                backgroundColor: Colors.transparent,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
          // Center text
          Center(
            child: Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(
                fontSize: size * 0.25,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 