import 'package:flutter/material.dart';

import 'infinityComic.dart';

class InfinityDetail extends StatelessWidget {
  final InfinityComic infinityComic;

  InfinityDetail(this.infinityComic);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(infinityComic.title),
        ),
        body: Image.network(
          infinityComic.cover,
        ));
  }
}
