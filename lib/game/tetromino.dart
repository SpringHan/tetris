import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';

import './world.dart';
import './block.dart';
import './display_tetro.dart';

enum TetrominoState {
  falling,
  moveless
}

enum MoveCommand {
  left,
  right,
  none
}

class Tetromino extends Component
with HasWorldReference<Screen> {
  Tetromino(DisplayTetromino dTetro)
  : tetroType = dTetro.tetroType {
    blocks = dTetro.blocks;
  }

  final String tetroType;
  final List<int> remainingBlocks = [0, 1, 2, 3];

  int tetroStyle = 0;
  bool moveLock = false;
  bool deletedFullLines = false;
  double delayTime = 0.5;
  List<int> positionInEmu = []; // The position in emulator array.
  List<BlockSprite> blocks = [];
  TetrominoState state = TetrominoState.falling;

  @override
  FutureOr<void> onLoad() async {
    final positions = tetrominoMap[tetroType]![tetroStyle];
    final targetObject = world.blockObjects[4];
    final targetPosition = Vector2(targetObject.x, targetObject.y);

    for (var i = 0; i <= 3; i++) {
      blocks[i].position = targetPosition + positions[i] * 64;
    }

    positionInEmu = world.newEmuPosition(
      init: 4,
      tetroType: tetroType
    )!;

    if (!_canMove([], positionInEmu)) {
      remainingBlocks.clear();
      world.changeRunningState();
    }

    addAll(blocks);
  }

  @override
  void update(double dt) {
    if (moveLock) return;

    if (world.blocksBeRemoved.isNotEmpty) {
      if (!deletedFullLines) _removeFullLines();
      return;
    } else if (deletedFullLines) {
      deletedFullLines = false;
    }

    if (state == TetrominoState.moveless) return;
    // _rotateBlocks();
    _updateHorizontal();
    _updateFalling(dt);
  }

  @override
  void onRemove() {
    for (final i in remainingBlocks) {
      blocks[i].removeFromParent();
    }
  }

  void _updateFalling(double dt) {
    if (delayTime > 0) {
      delayTime -= dt;
      return;
    }

    // final newBoundaries = _newBoundaries(y: 1);
    final newPosition = world.newEmuPosition(
      y: 1,
      tetroType: tetroType,
      positions: positionInEmu
    );

    // TODO: Debug
    if (!_canMove([], newPosition)) {
      _beMoveless();
      return;
    }

    for (final b in blocks) {
      b.moveDown();
    }
    positionInEmu = newPosition!;

    delayTime = world.delayLimit;
    world.restoreSpeed();
  }

  void _updateHorizontal() {
    final move = world.moveCommand;
    if (move == MoveCommand.none) return;

    final double horizontalMove;
    if (move == MoveCommand.left) {
      horizontalMove = -1;
    } else {
      horizontalMove = 1;
    }

    // final newBoundaries = _newBoundaries(x: horizontalMove);
    final newPositions = world.newEmuPosition(
      x: horizontalMove,
      tetroType: tetroType,
      positions: positionInEmu
    );

    if (!_canMove([], newPositions)) {
      return;
    }

    for (final b in blocks) {
      b.moveHorizontal(left: horizontalMove < 0);
    }

    positionInEmu = newPositions!;
    world.moveCommand = MoveCommand.none;
  }

  void _rotateBlocks() {
    if (!world.toRotate) return;

    int newStyleIdx = tetroStyle;
    final int center;
    final List<Vector2> relativePos;
    final tetroStyles = tetrominoMap[tetroType]!;

    if (tetroStyles.length == 1) return;

    if (tetroStyles.length == newStyleIdx + 1) {
      newStyleIdx = 0;
    } else {
      newStyleIdx++;
    }

    relativePos = tetroStyles[newStyleIdx];
    center = rotateCenter[tetroType]![newStyleIdx];

    final centerPos = positionInEmu[center];
    final newPositions = world.newEmuPosition(
      init: centerPos,
      style: tetroStyle,
      tetroType: tetroType
    );

    if (!_canMove([], newPositions)) return;

    positionInEmu = newPositions!;
    final targetObject = world.blockObjects[centerPos];
    final targetPosition = Vector2(targetObject.x, targetObject.y);

    for (var i = 0; i < 4; i++) {
      blocks[i].position = targetPosition + relativePos[i] * 64;
    }

    world.toRotate = false;
  }

  // NOTE: Check all the details then deciding
  // whether current movement can be executed.
  bool _canMove(List<double> boundaries, List<int>? position) {
    if (position == null) return false;

    // When initialize tetromino, boundaries can be empty.
    if (boundaries.isNotEmpty) {
      if (boundaries[0] > world.borders[1]
        || boundaries[1] < world.borders[2]
        || boundaries[2] > world.borders[3]) return false;
    }

    for (final p in position) {
      if (world.tetrisEmulator[p] == 1) return false;
    }

    return true;
  }

  // NOTE: Call this function after calling rotate.
  // List<double> _newBoundaries({double x = 0, double y = 0}) {
  //   final List<double> xList = [];
  //   final List<double> yList = [];
  //   for (final block in blocks) {
  //     xList.add(block.x + x * 64);
  //     yList.add(block.y + y * 64);
  //   }

  //   return [
  //     yList.reduce(max),
  //     xList.reduce(min),
  //     xList.reduce(max)
  //   ];
  // }

  // Remove the blocks included in full lines. Then move remaining blocks down.
  void _removeFullLines() {
    for (var i = 0; i < 4; i++) {
      final tempPosition = positionInEmu[i];
      if (world.blocksBeRemoved.contains(tempPosition)
        && remainingBlocks.contains(i)) {
        world.blocksBeRemoved.remove(tempPosition);
        blocks[i].removeFromParent();
        remainingBlocks.remove(i);
        continue;
      }

      if (tempPosition <= world.moveLines!.$1) {
        blocks[i].moveDown(times: world.moveLines!.$2.toDouble());
        positionInEmu[i] += world.moveLines!.$2 * 10;
      }
    }

    deletedFullLines = true;
    if (remainingBlocks.isEmpty) {
      world.removeEmptyTetro(this);
    }
  }

  void _beMoveless() {
    // Record positions of moveless blocks.
    for (final p in positionInEmu) {
      world.tetrisEmulator[p] = 1;
    }

    state = TetrominoState.moveless;
    world.restoreSpeed();
    world.moveCommand = MoveCommand.none;
    world.tetrominoFinished++;
    world.checkLines();
  }
}
