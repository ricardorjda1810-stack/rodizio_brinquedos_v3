import 'dart:async';

import 'package:flutter/material.dart';

import '../../app_state.dart';
import '../theme/ui_tokens.dart';

final class InterventionPage extends StatefulWidget {
  const InterventionPage({super.key});

  @override
  State<InterventionPage> createState() => _InterventionPageState();
}

final class _InterventionPageState extends State<InterventionPage> {
  static const _totalSeconds = 120;
  static const _cycleSeconds = 10;

  Timer? _timer;
  int _remainingSeconds = _totalSeconds;
  bool _isRunning = false;
  bool _feedbackSheetShown = false;

  bool get _isComplete => _remainingSeconds == 0;

  String get _phase {
    final elapsed = _totalSeconds - _remainingSeconds;
    final cyclePosition = elapsed % _cycleSeconds;
    return cyclePosition < 4 ? 'Inspire' : 'Expire';
  }

  double get _progress {
    return (_totalSeconds - _remainingSeconds) / _totalSeconds;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggleTimer() {
    if (_isComplete) {
      _reset();
      return;
    }

    setState(() => _isRunning = !_isRunning);

    if (_isRunning) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    } else {
      _timer?.cancel();
    }
  }

  void _tick() {
    if (_remainingSeconds <= 1) {
      _timer?.cancel();
      setState(() {
        _remainingSeconds = 0;
        _isRunning = false;
      });
      _showFeedbackSheet();
      return;
    }

    setState(() => _remainingSeconds--);
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _remainingSeconds = _totalSeconds;
      _isRunning = false;
      _feedbackSheetShown = false;
    });
  }

  Future<void> _showFeedbackSheet() async {
    if (_feedbackSheetShown || !mounted) {
      return;
    }

    setState(() => _feedbackSheetShown = true);

    final feedback = await showModalBottomSheet<String>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      builder: (context) => const _FeedbackSheet(),
    );

    if (!mounted || feedback == null) {
      return;
    }

    AppStateScope.of(context).completeActiveEvent(feedback);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Intervenção')),
      body: ListView(
        padding: const EdgeInsets.all(UiTokens.m),
        children: [
          const _IntroCard(),
          const SizedBox(height: UiTokens.xl),
          _BreathingTimer(
            phase: _phase,
            remainingSeconds: _remainingSeconds,
            progress: _progress,
          ),
          const SizedBox(height: UiTokens.xl),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _reset,
                  child: const Text('Reiniciar'),
                ),
              ),
              const SizedBox(width: UiTokens.s),
              Expanded(
                child: FilledButton(
                  onPressed: _toggleTimer,
                  child: Text(_isRunning ? 'Pausar' : 'Iniciar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

final class _IntroCard extends StatelessWidget {
  const _IntroCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(UiTokens.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Regulação guiada',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: UiTokens.s),
            const Text(
              'Uma regulação curta pode ajudar agora. Faça 2 minutos de respiração guiada para apoiar a redução da ativação fisiológica.',
              style: TextStyle(color: UiTokens.textSoft, height: 1.35),
            ),
          ],
        ),
      ),
    );
  }
}

final class _BreathingTimer extends StatelessWidget {
  const _BreathingTimer({
    required this.phase,
    required this.remainingSeconds,
    required this.progress,
  });

  final String phase;
  final int remainingSeconds;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox.square(
        dimension: 240,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox.square(
              dimension: 220,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 14,
                backgroundColor: UiTokens.border,
                color: UiTokens.secondary,
                strokeCap: StrokeCap.round,
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  phase,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: UiTokens.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: UiTokens.s),
                const Text(
                  'Inspire 4s · Expire 6s',
                  style: TextStyle(color: UiTokens.textFaint),
                ),
                const SizedBox(height: UiTokens.m),
                Text(
                  _formatRemaining(remainingSeconds),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _formatRemaining(int seconds) {
    final minutes = seconds ~/ 60;
    final rest = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${rest.toString().padLeft(2, '0')}';
  }
}

final class _FeedbackSheet extends StatelessWidget {
  const _FeedbackSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(UiTokens.l),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Você está melhor?',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: UiTokens.m),
            FilledButton(
              onPressed: () => Navigator.of(context).pop('Sim, melhorei'),
              child: const Text('Sim, melhorei'),
            ),
            const SizedBox(height: UiTokens.s),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop('Mais ou menos'),
              child: const Text('Mais ou menos'),
            ),
            const SizedBox(height: UiTokens.s),
            OutlinedButton(
              onPressed: () =>
                  Navigator.of(context).pop('Não, ainda preciso de apoio'),
              child: const Text('Não, ainda preciso de apoio'),
            ),
          ],
        ),
      ),
    );
  }
}
