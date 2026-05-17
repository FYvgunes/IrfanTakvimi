import 'package:flutter/widgets.dart';

import '../../core/services/location_service.dart';

typedef PermissionChildBuilder = Widget Function(
  BuildContext context,
  LocationPermissionResult status,
);

class PermissionGate extends StatefulWidget {
  final ILocationService service;
  final PermissionChildBuilder builder;

  const PermissionGate({
    super.key,
    required this.service,
    required this.builder,
  });

  @override
  State<PermissionGate> createState() => _PermissionGateState();
}

class _PermissionGateState extends State<PermissionGate> {
  LocationPermissionResult? _status;

  @override
  void initState() {
    super.initState();
    _ask();
  }

  Future<void> _ask() async {
    final r = await widget.service.requestPermission();
    if (mounted) setState(() => _status = r);
  }

  @override
  Widget build(BuildContext context) {
    final s = _status;
    if (s == null) return const SizedBox.shrink();
    return widget.builder(context, s);
  }
}
