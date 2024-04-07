import 'dart:async';

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
  right
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

    if (!_canMove(positionInEmu)) {
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
    updateFalling(dt);
  }

  @override
  void onRemove() {
    for (final i in remainingBlocks) {
      blocks[i].removeFromParent();
    }
  }

  void updateFalling(double dt) {
    if (delayTime > 0) {
      delayTime -= dt;
      return;
    }

    final newPosition = world.newEmuPosition(
      y: 1,
      tetroType: tetroType,
      positions: positionInEmu
    );

    if (!_canMove(newPosition)) {
      _beMoveless();
      return;
    }

    for (final b in blocks) {
      b.moveDown();
    }
    positionInEmu = newPosition!;

    delayTime = world.scoreComponent.limitTime;
  }

  void updateHorizontal(double horizontalMove) {
    moveLock = true;

    final newPositions = world.newEmuPosition(
      x: horizontalMove,
      tetroType: tetroType,
      positions: positionInEmu
    );

    if (!_canMove(newPositions)) {
      moveLock = false;
      return;
    }

    for (final b in blocks) {
      b.moveHorizontal(left: horizontalMove < 0);
    }

    positionInEmu = newPositions!;
    moveLock = false;
  }

  void rotateBlocks() {
    moveLock = true;

    int newStyleIdx = tetroStyle;
    final (int, Vector2?) center;
    final List<Vector2> relativePos;
    final tetroStyles = tetrominoMap[tetroType]!;

    if (tetroStyles.length == 1) {
      moveLock = false;
      return;
    }

    if (tetroStyles.length == newStyleIdx + 1) {
      newStyleIdx = 0;
    } else {
      newStyleIdx++;
    }

    relativePos = tetroStyles[newStyleIdx];
    center = rotateCenter[tetroType]![newStyleIdx];

    var centerPos = positionInEmu[center.$1];
    if (center.$2 != null) {
      var temp = makeEmuPos(
        centerPos,
        x: center.$2!.x,
        y: center.$2!.y
      );

      // NOTE: Bug may occur.
      if (temp == null) {
        moveLock = false;
        return;
      }
      centerPos = temp;
    }

    final newPositions = world.newEmuPosition(
      init: centerPos,
      style: newStyleIdx,
      tetroType: tetroType
    );

    if (!_canMove(newPositions)) {
      moveLock = false;
      return;
    }

    final targetObject = world.blockObjects[centerPos];
    final targetPosition = Vector2(targetObject.x, targetObject.y);

    for (var i = 0; i < 4; i++) {
      blocks[i].position = targetPosition + relativePos[i] * 64;
    }

    positionInEmu = newPositions!;
    tetroStyle = newStyleIdx;
    moveLock = false;
  }

  // NOTE: Check all the details then deciding
  // whether current movement can be executed.
  bool _canMove(List<int>? position) {
    if (position == null) return false;

    for (final p in position) {
      if (world.tetrisEmulator[p] == 1) return false;
    }

    return true;
  }

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

      final downLines = _linesToMove(tempPosition);
      if (downLines > 0) {
        blocks[i].moveDown(times: downLines.toDouble());
        positionInEmu[i] += downLines * 10;
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
    world.checkLines();
  }

  int _linesToMove(int position) {
    int line = 0;

    for (final i in world.removedLines) {
      if (position <= i) line++;
    }

    return line;
  }
}
