import 'dart:async';

import 'package:flame/components.dart';

class BlockSprite extends SpriteComponent {
  BlockSprite({
      super.priority,
      required super.position,
      required this.blockImage
  });

  final String blockImage;
  
  @override
  FutureOr<void> onLoad() async {
    size = Vector2.all(64.0);
    sprite = await Sprite.load(blockImage);
  }

  void moveDown({double times = 1}) {
    position += Vector2(0, 64 * times);
  }

  void moveHorizontal({required bool left}) {
    if (left) {
      position -= Vector2(64, 0);
      return;
    }

    position += Vector2(64, 0);
  }
}

final tetrominoMap = <String, List<Vector2>> {
  "I": [Vector2(0, 0), Vector2(0, 1), Vector2(0, 2), Vector2(0, 3)],
  "O": [Vector2(0, 0), Vector2(0, 1), Vector2(1, 0), Vector2(1, 1)],
  "J": [Vector2(0, 0), Vector2(1, 0), Vector2(0, 1), Vector2(0, 2)],
  "L": [Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(1, 2)],
  "Z": [Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(2, 1)],
  "S": [Vector2(0, 0), Vector2(1, 0), Vector2(0, 1), Vector2(-1, 1)],
  "T": [Vector2(0, 0), Vector2(0, 1), Vector2(-1, 1), Vector2(1, 1)],
};
