import 'dart:async';
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
  final List<int> remainingBlocks = [0, 1, 2, 3];

  bool moveLock = false;
  bool deletedFullLines = false;
  double delayTime = 0.5;
  List<int> positionInEmu = []; // The position in emulator array.
  List<BlockSprite> blocks = [];
  TetrominoState state = TetrominoState.falling;

  @override
  FutureOr<void> onLoad() async {
    final positions = tetrominoMap[tetroType]!;
    final targetObject = world.blockObjects[4];
    final targetPosition = Vector2(targetObject.x, targetObject.y);

    blocks = positions.map((e) => BlockSprite(
        blockImage: blockImage,
        position: targetPosition + e * 64
    )).toList();

    positionInEmu = _newEmuPosition(init: true);

    addAll(blocks);
  }

  @override
  void update(double dt) {
    if (world.blocksBeRemoved.isNotEmpty) {
      if (!deletedFullLines) _removeFullLines();
      return;
    } else if (deletedFullLines) {
      deletedFullLines = false;
    }

    _updateFalling(dt);
  }

  @override
  void onRemove() {
    for (final i in remainingBlocks) {
      remove(blocks[i]);
    }
  }

  void _updateFalling(double dt) {
    if (state == TetrominoState.moveless) return;

    if (delayTime > 0) {
      // if (moveLock) moveLock = false;
      delayTime -= dt;
      return;
    }

    // if (moveLock) return;

    final newBoundaries = _newBoundaries(y: 1);
    final newPosition = _newEmuPosition(y: 1);

    if (!_canMove(newBoundaries, newPosition)) {
      _beMoveless();
      return;
    }

    for (final b in blocks) {
      b.moveDown();
    }
    positionInEmu = newPosition;

    delayTime = 0.5;
  }

  // NOTE: Check all the details then deciding
  // whether current movement can be executed.
  bool _canMove(List<double> boundaries, List<int> position) {
    if (boundaries[0] > world.borders[1]
      || boundaries[1] < world.borders[2]
      || boundaries[2] > world.borders[3]) return false;

    for (final p in position) {
      if (world.tetrisEmulator[p] == 1) return false;
    }

    return true;
  }

  // NOTE: Call this function after calling rotate.
  List<double> _newBoundaries({double x = 0, double y = 0}) {
    final List<double> xList = [];
    final List<double> yList = [];
    for (final block in blocks) {
      xList.add(block.x + x * 64);
      yList.add(block.y + y * 64);
    }

    return [
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
        remainingBlocks.remove(i);
        continue;
      }

      if (tempPosition <= world.moveLines!.$1) {
        blocks[i].moveDown(times: world.moveLines!.$2 as double);
        positionInEmu[i] += world.moveLines!.$2 * 10;
      }
    }

    deletedFullLines = true;
    if (remainingBlocks.isEmpty) {
      world.removeEmptyTetro(this);
    }
  }

  void _beMoveless() {
    state = TetrominoState.moveless;
    world.tetrominoFinished++;
  }
}
