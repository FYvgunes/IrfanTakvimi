import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PlatformAwareScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;

  const PlatformAwareScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final isIos = Theme.of(context).platform == TargetPlatform.iOS;
    if (isIos) {
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text(title),
          trailing: actions == null || actions!.isEmpty
              ? null
              : Row(mainAxisSize: MainAxisSize.min, children: actions!),
        ),
        child: SafeArea(child: body),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(title), actions: actions),
      body: SafeArea(child: body),
    );
  }
}
