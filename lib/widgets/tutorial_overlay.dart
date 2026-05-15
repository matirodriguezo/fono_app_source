import 'dart:async';
import 'package:flutter/material.dart';

class TutorialStep {
  final String title;
  final String description;
  final IconData icon;

  const TutorialStep({
    required this.title,
    required this.description,
    required this.icon,
  });
}

Future<void> mostrarTutorial(BuildContext context, List<TutorialStep> pasos, VoidCallback onComplete) async {
  for (int i = 0; i < pasos.length; i++) {
    final paso = pasos[i];
    final isLast = i == pasos.length - 1;
    final completer = Completer<void>();

    if (!context.mounted) return;
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      builder: (ctx) => PopScope(
        canPop: true,
        child: AlertDialog(
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1E293B) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(paso.icon, color: Colors.blueAccent, size: 28),
              ),
              const SizedBox(height: 16),
              Text(
                paso.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                paso.description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.blueGrey.shade300 : Colors.blueGrey.shade600,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    completer.complete();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    isLast ? 'COMENZAR' : 'SIGUIENTE',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    await completer.future;
  }

  if (context.mounted) onComplete();
}

