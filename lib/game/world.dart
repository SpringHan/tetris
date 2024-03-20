import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';

import './block.dart';

class Screen extends World {
  late TiledComponent backgroundScreen;
  late List<TiledObject> blockObjects;
  final List<BlockSprite> blockList = [];

  @override
  FutureOr<void> onLoad() async {
    backgroundScreen = await TiledComponent.load("Main.tmx", Vector2.all(16));

    blockObjects = backgroundScreen.tileMap.getLayer<ObjectGroup>("Block")!.objects;

    final test = blockObjects[0];
    final blockSprite = BlockSprite(
      position: Vector2(test.x,test.y),
      blockImage: _getNewBlock(),
    );

    addAll([
        backgroundScreen,
        blockSprite
    ]);
    super.onLoad();
  }
}

String _getNewBlock() {
  return blockImages[
    blockTypes[Random().nextInt(7)]!
  ]!;
}

final blockTypes = <int, String> {
  0: "I",
  1: "J",
  2: "L",
  3: "O",
  4: "S",
  5: "T",
  6: "Z"
};

final blockImages = <String, String> {
  "I": "LightBlue.png",
  "J": "Blue.png",
  "L": "Orange.png",
  "O": "Yellow.png",
  "S": "Green.png",
  "T": "Purple.png",
  "Z": "Red.png"
};
