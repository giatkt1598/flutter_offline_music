import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';

class LanguageFlagIcon extends StatelessWidget {
  const LanguageFlagIcon({super.key, required this.languageCode});

  final String languageCode;

  @override
  Widget build(BuildContext context) {
    return languageCode == 'auto'
        ? Icon(Icons.language)
        : CountryFlag.fromLanguageCode(
          languageCode,
          height: 16,
          width: 24,
          shape: RoundedRectangle(2),
        );
  }
}
