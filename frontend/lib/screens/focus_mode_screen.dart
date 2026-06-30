import 'dart:async';
import 'package:flutter/material.dart';

class FocusModeScreen extends StatefulWidget {
  const FocusModeScreen({super.key});

  @override
  State<FocusModeScreen> createState() => _FocusModeScreenState();
}

class _FocusModeScreenState extends State<FocusModeScreen> {
  Timer? _timer;
  int _secondsRemaining = 25 * 60; // 25 minutes default
  bool _isRunning = false;

  void _toggleTimer() {
    if (_isRunning) {
      _timer?.cancel();
      setState(() => _isRunning = false);
    } else {
      setState(() => _isRunning = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_secondsRemaining > 0) {
          setState(() => _secondsRemaining--);
        } else {
          _timer?.cancel();
          setState(() {
            _isRunning = false;
            _secondsRemaining = 25 * 60;
          });
        }
      });
    }
  }

  String _formatDuration(int seconds) {
    final int mins = seconds ~/ 60;
    final int secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('Focus Session'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'FOCUSING ON',
                style: TextStyle(
                  color: colors.onSurface.withOpacity(0.5),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Compiler AST Parser Coding',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              
              // Timer Dial
              Container(
                height: 240,
                width: 240,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.surface,
                  border: Border.all(
                    color: _isRunning ? colors.secondary : colors.primary.withOpacity(0.4),
                    width: 6,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (_isRunning ? colors.secondary : colors.primary).withOpacity(0.1),
                      blurRadius: 32,
                      spreadRadius: 8,
                    )
                  ],
                ),
                child: Text(
                  _formatDuration(_secondsRemaining),
                  style: const TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 48),
              
              // Coach motivational note
              Text(
                '"One micro-step at a time. Write the class header first."',
                style: TextStyle(fontStyle: FontStyle.italic, color: colors.onSurface.withOpacity(0.7)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              
              // Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Reset/Complete
                  IconButton.filledTonal(
                    iconSize: 28,
                    icon: const Icon(Icons.stop),
                    onPressed: () {
                      _timer?.cancel();
                      setState(() {
                        _isRunning = false;
                        _secondsRemaining = 25 * 60;
                      });
                    },
                  ),
                  const SizedBox(width: 24),
                  
                  // Pause / Start
                  ElevatedButton(
                    onPressed: _toggleTimer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isRunning ? colors.error : colors.primary,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: Text(_isRunning ? 'Pause' : 'Start Focus'),
                  ),
                  const SizedBox(width: 24),
                  
                  // Add time
                  IconButton.filledTonal(
                    iconSize: 28,
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      setState(() => _secondsRemaining += 5 * 60);
                    },
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
