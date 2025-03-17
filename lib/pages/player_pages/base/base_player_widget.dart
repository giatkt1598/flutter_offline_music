import 'package:flutter/material.dart';
import 'package:flutter_offline_music/models/music.dart';

abstract class BasePlayerWidget extends StatefulWidget {
  const BasePlayerWidget({super.key, required this.music});

  final Music music;

  @override
  State<BasePlayerWidget> createState();
}
