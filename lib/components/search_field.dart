import 'dart:async';

import 'package:flutter/material.dart';

class SearchField extends StatefulWidget {
  const SearchField({super.key, this.onSubmitted});

  final ValueChanged<String>? onSubmitted;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  final TextEditingController _searchInputController = TextEditingController();
  final Duration _debounceDuration = Duration(milliseconds: 500);
  Timer? _timer;
  String lastText = "";
  bool isTyping = false;

  void _startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(_debounceDuration, (timer) {
      if ((isTyping || lastText.isNotEmpty) &&
          lastText != _searchInputController.text &&
          widget.onSubmitted != null) {
        lastText = _searchInputController.text;

        widget.onSubmitted!(lastText);
      }

      if (!isTyping) {
        timer.cancel();
      }

      isTyping = false;
    });
  }

  void _onTextChanged(String value) {
    isTyping = true;
    if (_timer == null || !_timer!.isActive) {
      _startTimer();
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autofocus: true,
      textInputAction: TextInputAction.search,
      controller: _searchInputController,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.search),
        suffixIcon:
            _searchInputController.text.isEmpty
                ? null
                : IconButton(
                  onPressed: () {
                    _searchInputController.clear();
                    _onTextChanged(_searchInputController.text);
                    setState(() {});
                  },
                  icon: Icon(Icons.clear),
                ),
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(999),
        ),
        hintText: 'Tìm kiếm',
        contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        fillColor: Color.lerp(
          Theme.of(context).cardColor,
          Theme.of(context).textTheme.bodyMedium!.color!,
          0.1,
        ),
        filled: true,
      ),
      onChanged: (value) {
        setState(() {});
        _onTextChanged(value);
      },
      style: TextStyle(fontSize: 14),
    );
  }
}
