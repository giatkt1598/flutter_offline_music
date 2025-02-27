import 'package:flutter/material.dart';

class MenuPopover<T> extends StatefulWidget {
  const MenuPopover({
    super.key,
    required this.trigger,
    required this.options,
    this.onPopoverResult,
  });

  final Widget Function(Function() showPopover) trigger;
  final List<PopupMenuEntry<T>> options;
  final Function(T? result)? onPopoverResult;
  @override
  State<MenuPopover> createState() => _MenuPopoverState<T>();
}

class _MenuPopoverState<T> extends State<MenuPopover<T>> {
  final GlobalKey _raisePopoverControlKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    showPopover() async {
      final triggerWidgetPosition = (_raisePopoverControlKey.currentContext!
                  .findRenderObject()
              as RenderBox)
          .localToGlobal(Offset.zero);
      final menuResult = await showMenu<T>(
        context: context,
        position: RelativeRect.fromLTRB(
          triggerWidgetPosition.dx,
          triggerWidgetPosition.dy + 50,
          0,
          0,
        ),
        items: widget.options,
      );

      if (widget.onPopoverResult != null) {
        widget.onPopoverResult!(menuResult);
      }
    }

    return Container(
      key: _raisePopoverControlKey,
      child: widget.trigger(showPopover),
    );
  }
}
