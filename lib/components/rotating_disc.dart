import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_offline_music/providers/player_provider.dart';
import 'package:provider/provider.dart';

class RotatingDisc extends StatefulWidget {
  const RotatingDisc({super.key});

  @override
  State<RotatingDisc> createState() => _RotatingDiscState();
}

class _RotatingDiscState extends State<RotatingDisc>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 20),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void play() {
    _controller.repeat();
  }

  void stop() {
    _controller.stop();
  }

  @override
  Widget build(BuildContext context) {
    final isPlaying = Provider.of<PlayerProvider>(context).isPlaying;
    if (isPlaying) {
      play();
    } else {
      stop();
    }

    double size =
        min(
          MediaQuery.of(context).size.width,
          MediaQuery.of(context).size.height,
        ) *
        0.8;

    size = min(size, 300);

    return RotationTransition(
      turns: _controller,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: AssetImage('assets/disc_2.png'), // Đĩa nhạc
            fit: BoxFit.cover,
          ),
          boxShadow: [
            BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 2),
          ],
        ),
      ),
    );
  }
}
