import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PlatformAwareButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const PlatformAwareButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isIos = Theme.of(context).platform == TargetPlatform.iOS;
    if (isIos) {
      return CupertinoButton.filled(
        onPressed: onPressed,
        child: Text(label),
      );
    }
    return ElevatedButton(onPressed: onPressed, child: Text(label));
  }
}
