import 'dart:math';

import 'package:flame/components.dart';

import './world.dart';
import './block.dart';

enum TetrominoState {
  falling,
  moveless
}

enum MoveCommand {
  left,
  right,
  none
}

class Tetromino extends Component with HasWorldReference<Screen> {
  Tetromino({
      required this.tetroType,
      required this.blockImage,
  });

  final String tetroType;
  final String blockImage;

  List<double> blockBoundaries = [];

  bool moveLock = false;
  double delayTime = 0.5;
  List<BlockSprite> blocks = [];
  TetrominoState state = TetrominoState.falling;

  @override
  Future<void> onLoad() async {
    final positions = tetrominoMap[tetroType]!;
    final targetObject = world.blockObjects[4];
    final targetPosition = Vector2(targetObject.x, targetObject.y);

    blocks = positions.map((e) => BlockSprite(
        blockImage: blockImage,
        position: targetPosition + e * 64
    )).toList();

    _initBoundaries();

    addAll(blocks);
    super.onLoad();
  }

  @override
  void update(double dt) {
    _updateFalling();
  }

  void _updateFalling() {
    if (state == TetrominoState.moveless) return;
  }

  // NOTE: Check all the details then deciding whether current movement can be executed.
  bool _canMove(bool horizontal) {
    // TODO: To be modified.
    if (horizontal) {
    }

    return true;
  }

  // NOTE: Call this function after calling rotate.
  void _initBoundaries() {
    final List<double> xList = [];
    final List<double> yList = [];
    for (final block in blocks) {
      xList.add(block.x);
      yList.add(block.y);
    }

    blockBoundaries = [
      yList.reduce(min),
      yList.reduce(max),
      xList.reduce(min),
      xList.reduce(max)
    ];
  }
}

final tetrominoMap = <String, List<Vector2>> {
  "I": [Vector2(0, 0), Vector2(0, 1), Vector2(0, 2), Vector2(0, 3)],
  "O": [Vector2(0, 0), Vector2(0, 1), Vector2(1, 0), Vector2(1, 1)],
  "J": [Vector2(0, 0), Vector2(1, 0), Vector2(0, 1), Vector2(0, 2)],
  "L": [Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(1, 2)],
  "Z": [Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(2, 1)],
  "S": [Vector2(0, 0), Vector2(1, 0), Vector2(0, 1), Vector2(-1, 1)],
};
