import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CupertinoTimePickerExample extends StatefulWidget {
  const CupertinoTimePickerExample({super.key});

  @override
  _CupertinoTimePickerExampleState createState() =>
      _CupertinoTimePickerExampleState();
}

class _CupertinoTimePickerExampleState
    extends State<CupertinoTimePickerExample> {
  Duration selectedTime = Duration(hours: 0, minutes: 0);

  void _showCupertinoPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext builder) {
        return SizedBox(
          height: 250,
          child: CupertinoTimerPicker(
            mode: CupertinoTimerPickerMode.hm,
            onTimerDurationChanged: (Duration newTime) {
              setState(() {
                selectedTime = newTime;
              });
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chọn Giờ iOS Style")),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Giờ đã chọn: ${selectedTime.inHours}:${selectedTime.inMinutes % 60}",
            ),
            ElevatedButton(
              onPressed: () => _showCupertinoPicker(context),
              child: Text("Chọn giờ"),
            ),
          ],
        ),
      ),
    );
  }
}
