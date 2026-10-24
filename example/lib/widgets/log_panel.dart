import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/action_log.dart';

/// Bottom panel listing the most recent results, newest first.
class LogPanel extends StatelessWidget {
  const LogPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final log = context.watch<ActionLog>();
    final entries = log.entries;
    final theme = Theme.of(context);

    return Material(
      elevation: 8,
      color: theme.colorScheme.surfaceContainerHighest,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 180,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 4, 0),
                child: Row(
                  children: [
                    const Icon(Icons.terminal, size: 18),
                    const SizedBox(width: 8),
                    Text('Results', style: theme.textTheme.titleSmall),
                    const Spacer(),
                    TextButton(
                      onPressed: entries.isEmpty ? null : log.clear,
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: entries.isEmpty
                    ? Center(
                        child: Text(
                          'Tap an action to see its result here.',
                          style: theme.textTheme.bodySmall,
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        itemCount: entries.length,
                        itemBuilder: (context, i) =>
                            _LogRow(entry: entries[i]),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogRow extends StatelessWidget {
  const _LogRow({Key? key, required this.entry}) : super(key: key);

  final LogEntry entry;

  static const _icons = {
    LogLevel.info: Icons.info_outline,
    LogLevel.success: Icons.check_circle_outline,
    LogLevel.error: Icons.error_outline,
    LogLevel.incoming: Icons.call_received,
  };

  static const _colors = {
    LogLevel.info: Colors.blueGrey,
    LogLevel.success: Colors.green,
    LogLevel.error: Colors.red,
    LogLevel.incoming: Colors.purple,
  };

  @override
  Widget build(BuildContext context) {
    final t = entry.time;
    final time = '${_two(t.hour)}:${_two(t.minute)}:${_two(t.second)}';
    final style = Theme.of(context).textTheme.bodySmall;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_icons[entry.level], size: 16, color: _colors[entry.level]),
          const SizedBox(width: 8),
          Text(time, style: style?.copyWith(fontFamily: 'monospace')),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '${entry.title}: ',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: entry.message),
                ],
              ),
              style: style,
            ),
          ),
        ],
      ),
    );
  }

  static String _two(int n) => n.toString().padLeft(2, '0');
}
