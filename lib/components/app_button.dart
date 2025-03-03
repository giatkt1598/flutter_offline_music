import 'package:flutter/material.dart';

enum AppButtonType { primary, secondary }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    this.child,
    this.onPressed,
    this.type = AppButtonType.secondary,
  });

  final Widget? child;
  final VoidCallback? onPressed;
  final AppButtonType type;
  @override
  Widget build(BuildContext context) {
    return type == AppButtonType.secondary
        ? OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              width: 3,
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
          ),

          child: child,
        )
        : ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            foregroundColor: Theme.of(context).textTheme.bodyMedium!.color,
            shadowColor: Colors.transparent,
          ),
          child: child,
        );
  }
}
