import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';

import './game.dart';

class BlockSprite extends SpriteComponent with HasGameRef<TetrisGame> {
  BlockSprite({int? priority, super.position}) {
    if (priority != null) {
      this.priority = priority;
    }
  }

  @override
  FutureOr<void> onLoad() async {
    size = Vector2.all(64.0);
    sprite = await Sprite.load(_getNewBlock());

    super.onLoad();
  }

  // @override
  // void update(double dt) {
  // }
}

String _getNewBlock() {
  // return blockImages[Random().nextInt(7)]!;
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
