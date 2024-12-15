// lib/screens/match/components/undo_redo_buttons.dart

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class UndoRedoButtons extends StatelessWidget {
  final bool canUndo;
  final bool canRedo;
  final VoidCallback? onUndo;
  final VoidCallback? onRedo;
  final bool showTooltips;
  final Color? activeColor;
  final Color? inactiveColor;

  const UndoRedoButtons({
    super.key,
    required this.canUndo,
    required this.canRedo,
    this.onUndo,
    this.onRedo,
    this.showTooltips = true,
    this.activeColor = Colors.blue,
    this.inactiveColor = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _buildActionButton(
          icon: Icons.undo,
          enabled: canUndo,
          onPressed: onUndo,
          tooltip: 'Undo last action',
        ),
        _buildActionButton(
          icon: Icons.redo,
          enabled: canRedo,
          onPressed: onRedo,
          tooltip: 'Redo last action',
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required bool enabled,
    VoidCallback? onPressed,
    required String tooltip,
  }) {
    final button = IconButton(
      icon: Icon(
        icon,
        color: enabled ? activeColor : inactiveColor,
        size: 20,
      ),
      onPressed: enabled ? onPressed : null,
      padding: const EdgeInsets.all(8),
      constraints: const BoxConstraints(
        minWidth: 32,
        minHeight: 32,
      ),
      splashRadius: 20,
    );

    return showTooltips
        ? Tooltip(
            message: tooltip,
            child: button,
          )
        : button;
  }
}

// Optional: Extended version with animations and badges
class UndoRedoButtonsExtended extends StatelessWidget {
  final bool canUndo;
  final bool canRedo;
  final VoidCallback? onUndo;
  final VoidCallback? onRedo;
  final int undoCount;
  final int redoCount;
  final bool showCounts;
  final Color? activeColor;
  final Color? inactiveColor;

  const UndoRedoButtonsExtended({
    super.key,
    required this.canUndo,
    required this.canRedo,
    this.onUndo,
    this.onRedo,
    this.undoCount = 0,
    this.redoCount = 0,
    this.showCounts = false,
    this.activeColor = Colors.blue,
    this.inactiveColor = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _buildAnimatedButton(
          icon: Icons.undo,
          enabled: canUndo,
          onPressed: onUndo,
          tooltip: 'Undo last action',
          count: undoCount,
        ),
        _buildAnimatedButton(
          icon: Icons.redo,
          enabled: canRedo,
          onPressed: onRedo,
          tooltip: 'Redo last action',
          count: redoCount,
        ),
      ],
    );
  }

  Widget _buildAnimatedButton({
    required IconData icon,
    required bool enabled,
    VoidCallback? onPressed,
    required String tooltip,
    required int count,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Tooltip(
          message: tooltip,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: enabled ? onPressed : null,
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: enabled
                      ? activeColor?.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  icon,
                  color: enabled ? activeColor : inactiveColor,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
        if (showCounts && count > 0)
          Positioned(
            right: -4,
            top: -4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: activeColor,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                count.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}

// Optional: Keyboard shortcuts handler
class UndoRedoShortcuts extends StatelessWidget {
  final Widget child;
  final VoidCallback? onUndo;
  final VoidCallback? onRedo;
  final bool enabled;

  const UndoRedoShortcuts({
    super.key,
    required this.child,
    this.onUndo,
    this.onRedo,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: enabled
          ? <ShortcutActivator, Intent>{
              LogicalKeySet(
                LogicalKeyboardKey.control,
                LogicalKeyboardKey.keyZ,
              ): const UndoIntent(),
              LogicalKeySet(
                LogicalKeyboardKey.control,
                LogicalKeyboardKey.keyY,
              ): const RedoIntent(),
              LogicalKeySet(
                LogicalKeyboardKey.control,
                LogicalKeyboardKey.shift,
                LogicalKeyboardKey.keyZ,
              ): const RedoIntent(),
            }
          : {},
      child: Actions(
        actions: <Type, Action<Intent>>{
          UndoIntent: CallbackAction<UndoIntent>(
            onInvoke: (UndoIntent intent) => onUndo?.call(),
          ),
          RedoIntent: CallbackAction<RedoIntent>(
            onInvoke: (RedoIntent intent) => onRedo?.call(),
          ),
        },
        child: child,
      ),
    );
  }
}

// Intents for keyboard shortcuts
class UndoIntent extends Intent {
  const UndoIntent();
}

class RedoIntent extends Intent {
  const RedoIntent();
}
