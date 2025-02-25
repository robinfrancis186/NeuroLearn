import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../services/performance_service.dart';

/// A widget that displays an image with performance optimizations
class OptimizedImage extends StatefulWidget {
  final String imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Color? color;
  final BorderRadius? borderRadius;

  const OptimizedImage({
    Key? key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.color,
    this.borderRadius,
  }) : super(key: key);

  @override
  State<OptimizedImage> createState() => _OptimizedImageState();
}

class _OptimizedImageState extends State<OptimizedImage> {
  Uint8List? _cachedImage;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(OptimizedImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imagePath != widget.imagePath) {
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final performanceService = PerformanceService();
      final cachedImage = await performanceService.getCachedAsset(widget.imagePath);
      
      if (mounted) {
        setState(() {
          _cachedImage = cachedImage;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;
    
    if (_isLoading) {
      // Show loading indicator while image is loading
      imageWidget = SizedBox(
        width: widget.width,
        height: widget.height,
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          ),
        ),
      );
    } else if (_cachedImage != null) {
      // Use memory image if cached
      imageWidget = Image.memory(
        _cachedImage!,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        color: widget.color,
      );
    } else {
      // Fallback to asset image
      imageWidget = Image.asset(
        widget.imagePath,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        color: widget.color,
      );
    }
    
    // Apply border radius if provided
    if (widget.borderRadius != null) {
      return ClipRRect(
        borderRadius: widget.borderRadius!,
        child: imageWidget,
      );
    }
    
    return imageWidget;
  }
} 