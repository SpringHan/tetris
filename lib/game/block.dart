import 'dart:async';

import 'package:flame/components.dart';

import './world.dart';

enum BlockState {
  falling,
  moveless
}

enum MoveCommand {
  left,
  right,
  none
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

  bool speedUp = false;
  bool moveLock = false;
  double movingSpeed = 64;
  BlockState blockState = BlockState.falling;

  @override
  FutureOr<void> onLoad() async {
    size = Vector2.all(64.0);
    sprite = await Sprite.load(blockImage);

    super.onLoad();
  }

  @override
  void update(double dt) {
    _detectDirection();
    _updateBlockMovement();
    super.update(dt);
  }

  void _updateBlockMovement() {
    if (blockState == BlockState.moveless) return;

    if (world.delayTime != 0) {
      // TODO: Add support for horizontal movement
      if (moveLock) moveLock = false;
      return;
    }

    if (moveLock) return;

    // TODO: To be modified.
    if (position.y == world.borders[1]) {
      blockState = BlockState.moveless;
      return;
    }

    position += Vector2(0, movingSpeed);
    moveLock = true;
  }

  void _detectDirection() {
    var move = 0.0;
    switch (world.moveCommand) {
      case MoveCommand.left:
      if (position.x == world.borders[2]
        // || ...
      ) return;
      move = -64.0;
      break;
      case MoveCommand.right:
      if (position.x == world.borders[3]) return;
      move = 64.0;
      default:
      return;
    }

    position += Vector2(move, 0);
    world.moveCommand = MoveCommand.none;
  }
}
