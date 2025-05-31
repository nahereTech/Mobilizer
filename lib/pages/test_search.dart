import 'package:flutter/material.dart';

class TestSearch extends StatelessWidget {
  const TestSearch({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: TextField(
        onChanged: (term) {},
      ),
    );
  }
}
