import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';

class Utils {
  static void showError(BuildContext context, {required String message}) =>
      showSimpleNotification(const Text("Notification"),
          subtitle: const Text("Serveur introuvable"),
          autoDismiss: true,
          background: Colors.red);

  static void showFinished(BuildContext context) =>
      showSimpleNotification(const Text("Notification"),
          subtitle: const Text("Envoi terminé"),
          autoDismiss: true,
          duration: const Duration(seconds: 3),
          background: const Color(0xFF1E40AF));

  static void showEstablished(
          BuildContext context, String message, bool dismissed) =>
      showSimpleNotification(
          const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Notification"),
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              ]),
          subtitle: Text(message),
          autoDismiss: dismissed,
          background: const Color(0xFF1E40AF));
}
