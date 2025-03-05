import 'package:flutter/material.dart';

class ButtonCard extends StatelessWidget {
  const ButtonCard({
    super.key,
    this.child,
    this.icon,
    this.onPressed,
    this.backgroundImage,
  });

  final Widget? child;
  final Widget? icon;
  final Function? onPressed;
  final ImageProvider<Object>? backgroundImage;
  @override
  Widget build(BuildContext context) {
    final shadowColor =
        Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black;
    return DefaultTextStyle(
      style: TextStyle(color: Colors.white),
      child: IconTheme(
        data: IconThemeData(color: Colors.white),
        child: Center(
          child: InkWell(
            onTap: () => onPressed != null ? onPressed!() : null,
            borderRadius: BorderRadius.circular(8),
            child: Ink(
              height: 64,
              decoration: BoxDecoration(
                image:
                    backgroundImage != null
                        ? DecorationImage(
                          image: backgroundImage!,
                          fit: BoxFit.cover, // Căn chỉnh hình nền
                        )
                        : null,
                borderRadius: BorderRadius.circular(8),
                color: Theme.of(context).colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color: shadowColor.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor.withValues(alpha: 0.5),
                    blurRadius: 24,
                    spreadRadius: -12,
                    // blurStyle: BlurStyle.solid,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
              child: Row(
                spacing: 6,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [if (icon != null) icon!, if (child != null) child!],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
