
import 'package:flutter/material.dart';

class VoiceButton extends StatefulWidget {
  final bool isListening;
  final bool isLoading;
  final VoidCallback onTapStart;
  final VoidCallback onTapEnd;
  final ColorScheme colorScheme;

  const VoiceButton({
    required this.isListening,
    required this.isLoading,
    required this.onTapStart,
    required this.onTapEnd,
    required this.colorScheme,
  });

  @override
  State<VoiceButton> createState() => _VoiceButtonState();
}

class _VoiceButtonState extends State<VoiceButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _ringOpacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
      lowerBound: 0.0,
      upperBound: 1.0,
    );

    _scaleAnim = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _ringOpacity = Tween<double>(begin: 0.4, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(covariant VoiceButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateAnimation();
  }

  void _updateAnimation() {
    if (widget.isListening && !widget.isLoading) {
      _controller.repeat();
    } else {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.isListening) {
          widget.onTapEnd();
        } else {
          widget.onTapStart();
        }
      },
      onLongPressStart: (_) => widget.onTapStart(),
      onLongPressEnd: (_) => widget.onTapEnd(),
      child: Semantics(
        button: true,
        label: widget.isListening
            ? 'Sedang mendengarkan. Lepas untuk berhenti'
            : 'Ketuk atau tahan untuk mulai bicara',
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                // Outer pulsing ring
                if (widget.isListening)
                  Container(
                    height: 120 * _scaleAnim.value,
                    width: 120 * _scaleAnim.value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red.withOpacity(_ringOpacity.value * 0.3),
                    ),
                  ),
                // Inner pulsing ring
                if (widget.isListening)
                  Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red.withOpacity(0.15),
                    ),
                  ),
                // Main mic button
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: widget.isListening
                        ? const LinearGradient(
                            colors: [Color(0xFFFF6B6B), Color(0xFFEE5A52)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : LinearGradient(
                            colors: [
                              widget.colorScheme.primary,
                              widget.colorScheme.primary.withOpacity(0.8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                    boxShadow: [
                      BoxShadow(
                        color: (widget.isListening
                                ? Colors.red
                                : widget.colorScheme.primary)
                            .withOpacity(0.4),
                        blurRadius: widget.isListening ? 28 : 16,
                        spreadRadius: widget.isListening ? 4 : 2,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: widget.isLoading
                      ? const Center(
                          child: SizedBox(
                            width: 32,
                            height: 32,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          ),
                        )
                      : Icon(
                          widget.isListening ? Icons.mic : Icons.mic_none_rounded,
                          size: 38,
                          color: Colors.white,
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}