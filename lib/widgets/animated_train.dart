import 'package:flutter/material.dart';

import '../model/train.dart';

/// A widget that animates train arrival/departure.
class AnimatedTrain extends StatefulWidget {
  final Train? train;

  const AnimatedTrain({
    super.key,
    required this.train,
  });

  @override
  State<AnimatedTrain> createState() => _AnimatedTrainState();
}

class _AnimatedTrainState extends State<AnimatedTrain>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  Train? _displayedTrain;

  @override
  void initState() {
    super.initState();
    _displayedTrain = widget.train;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _setupSlideInAnimation();

    // Start animation if there's an initial train
    if (_displayedTrain != null) {
      _controller.forward();
    }
  }

  /// Sets up the slide-in animation (from right to center)
  void _setupSlideInAnimation() {
    _slideAnimation = Tween<Offset>(
      begin: const Offset(3.0, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  /// Sets up the slide-out animation (from center to left)
  void _setupSlideOutAnimation() {
    _slideAnimation = Tween<Offset>(
      begin: const Offset(-3.0, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
  }

  @override
  void didUpdateWidget(covariant AnimatedTrain oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Only animate if the train changes
    final oldTrainNumber = oldWidget.train?.trainNumber;
    final newTrainNumber = widget.train?.trainNumber;

    if (oldTrainNumber != newTrainNumber) {
      if (oldWidget.train != null && widget.train != null) {
        // Animate old train out, then new train in
        _setupSlideOutAnimation();
        _controller.reverse().then((_) {
          setState(() {
            _displayedTrain = widget.train;
            _setupSlideInAnimation();
            _controller.forward(from: 0);
          });
        });
      } else if (widget.train != null) {
        // No previous train, just slide in new train
        setState(() {
          _displayedTrain = widget.train;
          _setupSlideInAnimation();
          _controller.forward(from: 0);
        });
      } else {
        // No train to display
        setState(() {
          _displayedTrain = null;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show train number with slide animation if present
    return _displayedTrain != null
        ? SlideTransition(
            position: _slideAnimation,
            child: Text(
              "🚄 ${_displayedTrain!.trainNumber}",
            ),
          )
        : SizedBox();
  }
}
