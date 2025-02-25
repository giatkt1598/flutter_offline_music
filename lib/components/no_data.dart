import 'package:flutter/material.dart';

class NoData extends StatelessWidget {
  const NoData({super.key, this.title});

  final String? title;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/no_data.png',
            width: MediaQuery.of(context).size.width * 0.7,
          ),
          Text(title ?? 'Không có dữ liệu'),
        ],
      ),
    );
  }
}
