import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';

class AutoScrollText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final bool? isCenter;
  final double? containerWidth;
  final bool? useDebug;

  const AutoScrollText({
    super.key,
    required this.text,
    this.style,
    this.isCenter,
    this.containerWidth,
    this.useDebug,
  });

  @override
  Widget build(BuildContext context) {
    double currentContainerWidth =
        containerWidth ?? MediaQuery.of(context).size.width;
    double fontSize = style?.fontSize ?? 16;
    return LayoutBuilder(
      builder: (context, constraints) {
        // Measure text width
        TextPainter textPainter = TextPainter(
          text: TextSpan(
            text: text,
            style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
          ),
          maxLines: 1,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: currentContainerWidth);

        bool shouldScroll =
            textPainter.width >=
            currentContainerWidth; // Check if text overflows
        var staticText = Text(
          text,
          style: style,
          overflow: TextOverflow.ellipsis, // Show "..." if it overflows
        );

        var result = SizedBox(
          height: fontSize + 10, // Ensure text fits properly
          width: currentContainerWidth,
          child:
              shouldScroll
                  ? Marquee(
                    text: text,
                    style: style,
                    scrollAxis: Axis.horizontal,
                    blankSpace: 50.0, // Space between repetitions
                    velocity: 20.0, // Speed of scrolling
                    pauseAfterRound: Duration(
                      seconds: 0,
                    ), // Pause before restarting
                    startPadding: 10.0,
                    accelerationDuration: Duration(seconds: 1),
                    accelerationCurve: Curves.linear,
                    decelerationDuration: Duration(milliseconds: 500),
                    decelerationCurve: Curves.easeOut,
                  )
                  : isCenter == true
                  ? Center(child: staticText)
                  : staticText,
        );

        if (useDebug == true) {
          return Row(
            children: [
              Container(
                width: currentContainerWidth,
                color: Colors.amber,
                child: result,
              ),
            ],
          );
        }

        return result;
      },
    );
  }
}
