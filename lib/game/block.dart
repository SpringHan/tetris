import 'dart:async';

import 'package:flame/components.dart';

import './world.dart';

enum BlockState {
  falling,
  moveless
}

class BlockSprite extends SpriteComponent
with HasWorldReference<Screen> {
  BlockSprite({
      int? priority,
      super.position,
      required this.blockImage
  })
  {
    if (priority != null) {
      this.priority = priority;
    }
  }

  final String blockImage;

  double movingSpeed = 8;
  BlockState blockState = BlockState.falling;

  @override
  FutureOr<void> onLoad() async {
    size = Vector2.all(64.0);
    sprite = await Sprite.load(blockImage);

    super.onLoad();
  }

  @override
  void update(double dt) {
    _updateBlockMovement();
    super.update(dt);
  }

  void _updateBlockMovement() {
    if (blockState == BlockState.falling) {
      if (position.y == world.blockObjects.last.y) {
        blockState = BlockState.moveless;
        return;
      }

      position += Vector2(0, movingSpeed);
    }
  }
}
