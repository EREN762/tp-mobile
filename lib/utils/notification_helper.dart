import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';

/// Helper class pour afficher des notifications modernes similaires à Sonner
class NotificationHelper {
  /// Affiche une notification de succès
  static void showSuccess(String message, {Duration? duration}) {
    showSimpleNotification(
      Text(
        message,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      background: const Color(0xFF4CAF50),
      duration: duration ?? const Duration(seconds: 3),
      slideDismissDirection: DismissDirection.up,
      position: NotificationPosition.top,
      leading: const Icon(Icons.check_circle, color: Colors.white),
    );
  }

  /// Affiche une notification d'erreur
  static void showError(String message, {Duration? duration}) {
    showSimpleNotification(
      Text(
        message,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      background: const Color(0xFFEF5350),
      duration: duration ?? const Duration(seconds: 3),
      slideDismissDirection: DismissDirection.up,
      position: NotificationPosition.top,
      leading: const Icon(Icons.error, color: Colors.white),
    );
  }

  /// Affiche une notification d'information
  static void showInfo(String message, {Duration? duration}) {
    showSimpleNotification(
      Text(
        message,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      background: const Color(0xFF5669FF),
      duration: duration ?? const Duration(seconds: 3),
      slideDismissDirection: DismissDirection.up,
      position: NotificationPosition.top,
      leading: const Icon(Icons.info, color: Colors.white),
    );
  }

  /// Affiche une notification d'avertissement
  static void showWarning(String message, {Duration? duration}) {
    showSimpleNotification(
      Text(
        message,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      background: const Color(0xFFFF9800),
      duration: duration ?? const Duration(seconds: 3),
      slideDismissDirection: DismissDirection.up,
      position: NotificationPosition.top,
      leading: const Icon(Icons.warning, color: Colors.white),
    );
  }

  /// Affiche une notification personnalisée
  static void showCustom({
    required String message,
    required Color backgroundColor,
    IconData? icon,
    Duration? duration,
    NotificationPosition? position,
  }) {
    showSimpleNotification(
      Text(
        message,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      background: backgroundColor,
      duration: duration ?? const Duration(seconds: 3),
      slideDismissDirection: DismissDirection.up,
      position: position ?? NotificationPosition.top,
      leading: icon != null ? Icon(icon, color: Colors.white) : null,
    );
  }
}

