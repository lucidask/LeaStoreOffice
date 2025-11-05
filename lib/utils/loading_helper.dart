import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

Future<void> executeWithLoading(BuildContext context, Future<void> Function() task) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator()),
  );

  // ✅ Capture une référence locale de context
  final currentContext = context;

  SchedulerBinding.instance.addPostFrameCallback((_) async {
    try {
      await task();
    } catch (e) {
      if (!currentContext.mounted) return;
      ScaffoldMessenger.of(currentContext).showSnackBar(
        SnackBar(content: Text('❌ Erreur : $e')),
      );
    } finally {
      if (currentContext.mounted) Navigator.of(currentContext).pop();
    }
  });
}
