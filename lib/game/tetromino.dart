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
  int remainingBlocks = 4;

  List<double> blockBoundaries = [];

  bool moveLock = false;
  bool deletedFullLines = false;
  double delayTime = 0.5;
  List<int> positionInEmu = []; // The position in emulator array.
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
    positionInEmu = _newEmuPosition(init: true);

    addAll(blocks);
    super.onLoad();
  }

  @override
  void update(double dt) {
    if (world.blocksBeRemoved.isNotEmpty) {
      if (!deletedFullLines) _removeFullLines();
      return;
    } else if (deletedFullLines) {
      deletedFullLines = false;
    }

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

  // NOTE: This function can only be called when the tetromino is falling.
  List<int> _newEmuPosition({
      bool init = false,
      double x = 0,
      double y = 0,
  }) {
    final List<int> temp = [];

    if (init) {
      temp.add(4);
    } else {
      temp.add(makeEmuPos(positionInEmu[0], x: x, y: y));
    }

    for (final e in tetrominoMap[tetroType]!) {
      if (e == Vector2(0, 0)) continue;
      temp.add(makeEmuPos(
          temp[0],
          x: e.x,
          y: e.y
      ));
    }

    return temp;
  }

  // Remove the blocks included in full lines. Then move remaining blocks down.
  void _removeFullLines() {
    for (var i = 0; i < 4; i++) {
      final tempPosition = positionInEmu[i];
      if (world.blocksBeRemoved.contains(tempPosition)) {
        world.blocksBeRemoved.remove(tempPosition);
        remove(blocks[i]);
        remainingBlocks--;
        continue;
      }

      if (tempPosition <= world.moveLines!.$1) {
        blocks[i].moveDown(times: world.moveLines!.$2 as double);
        positionInEmu[i] += world.moveLines!.$2 * 10;
      }
    }

    deletedFullLines = true;
    if (remainingBlocks == 0) {
      world.removeEmptyTetro(this);
    }
  }

  void _beMoveless() {
    state = TetrominoState.moveless;
    blockBoundaries.clear();
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
