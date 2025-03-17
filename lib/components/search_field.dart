import 'dart:async';

import 'package:flutter/material.dart';

class SearchField extends StatefulWidget {
  const SearchField({
    super.key,
    this.onChanged,
    this.autoFocus = false,
    this.initialValue,
    this.onSubmitted,
    this.hintText = 'Tìm kiếm',
  });

  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool autoFocus;
  final String? initialValue;
  final String hintText;
  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  final TextEditingController _searchInputController = TextEditingController();
  final Duration _debounceDuration = Duration(milliseconds: 500);
  Timer? _timer;
  String lastText = "";
  bool isTyping = false;

  @override
  void initState() {
    super.initState();
    _searchInputController.text = widget.initialValue ?? '';
  }

  void _startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(_debounceDuration, (timer) {
      if ((isTyping || lastText.isNotEmpty) &&
          lastText != _searchInputController.text &&
          widget.onChanged != null) {
        lastText = _searchInputController.text;

        widget.onChanged!(lastText);
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
  Widget build(BuildContext context) {
    return TextFormField(
      autofocus: widget.autoFocus,
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
        hintText: widget.hintText,
        contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        fillColor: Color.lerp(
          Theme.of(context).cardColor,
          Theme.of(context).textTheme.bodyMedium!.color!,
          0.1,
        ),
        filled: true,
      ),
      onFieldSubmitted: (value) {
        if (widget.onSubmitted != null) {
          widget.onSubmitted!(value);
        }
      },
      onChanged: (value) {
        setState(() {});
        _onTextChanged(value);
      },
      style: TextStyle(fontSize: 14),
    );
  }
}
