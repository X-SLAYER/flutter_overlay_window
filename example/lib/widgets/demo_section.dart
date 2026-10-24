import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/action_log.dart';

/// A single plugin call the tester can trigger. The value returned by [run]
/// is written to the results log.
class DemoAction {
  const DemoAction({
    required this.title,
    required this.icon,
    required this.run,
    this.description,
  });

  final String title;
  final String? description;
  final IconData icon;
  final Future<Object?> Function(BuildContext context) run;
}

/// A collapsible card grouping related [DemoAction]s.
class DemoSection extends StatelessWidget {
  const DemoSection({
    Key? key,
    required this.title,
    required this.icon,
    required this.actions,
    this.description,
    this.initiallyExpanded = false,
  }) : super(key: key);

  final String title;
  final String? description;
  final IconData icon;
  final List<DemoAction> actions;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        leading: CircleAvatar(
          backgroundColor: colors.primaryContainer,
          foregroundColor: colors.onPrimaryContainer,
          child: Icon(icon),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: description == null ? null : Text(description!),
        childrenPadding: const EdgeInsets.only(bottom: 8),
        children: [
          const Divider(height: 1),
          for (final action in actions) _ActionTile(action: action),
        ],
      ),
    );
  }
}

class _ActionTile extends StatefulWidget {
  const _ActionTile({Key? key, required this.action}) : super(key: key);

  final DemoAction action;

  @override
  State<_ActionTile> createState() => _ActionTileState();
}

class _ActionTileState extends State<_ActionTile> {
  bool _running = false;

  Future<void> _run() async {
    final log = context.read<ActionLog>();
    setState(() => _running = true);
    try {
      final result = await widget.action.run(context);
      log.add(widget.action.title, '${result ?? 'done'}', LogLevel.success);
    } catch (e) {
      log.add(widget.action.title, '$e', LogLevel.error);
    } finally {
      if (mounted) setState(() => _running = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final action = widget.action;
    return ListTile(
      leading: Icon(action.icon),
      title: Text(action.title),
      subtitle: action.description == null ? null : Text(action.description!),
      trailing: _running
          ? const SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.play_arrow_rounded),
      onTap: _running ? null : _run,
    );
  }
}
