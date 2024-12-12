

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playbazaar/games/games/puzzle/wall_blast_play_page.dart';

class BlockBlastApp extends StatelessWidget {
  const BlockBlastApp({super.key});

  @override
  Widget build(BuildContext context) {

    return GetMaterialApp(
      title: 'Block Blast',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WallBlastPlayPage(),
    );
  }
}