import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';

import './tetromino.dart';
import './button.dart';
import './display_tetro.dart';
import './block.dart' show tetrominoMap;
import './score.dart';

import '../scores_manager.dart';

class Screen extends World {
  // Basic variables.
  bool _running = false;
  bool _initialized = false;
  late final List<TiledObject> blockObjects;
  late final TiledComponent _backgroundScreen;
  late final List<TiledObject> nextBlockObjects;
  List<int> tetrisEmulator = List.filled(200, 0, growable: true);

  // The lines that have been removed. Stored using the index of last item.
  List<int> removedLines = []; 
  List<int> blocksBeRemoved = []; // The idx of blocks to be removed.

  late Score scoreComponent;
  final List<double> borders = [];
  final List<Tetromino> tetrominoList = [];
  DisplayTetromino? nextTetromino;

  @override
  FutureOr<void> onLoad() async {
    _backgroundScreen = await TiledComponent.load("Main.tmx", Vector2.all(16));

    blockObjects = _backgroundScreen.tileMap.getLayer<ObjectGroup>("Block")!.objects;
    nextBlockObjects = _backgroundScreen.tileMap.getLayer<ObjectGroup>("NextBlock")!.objects;

    _initScore();
    _initBorders();
    _initButtons();

    add(_backgroundScreen);
  }

  @override
  void update(double dt) {
    if (!_running) return;

    if (blocksBeRemoved.isNotEmpty) {
      return;
    }

    if (tetrominoList.isEmpty
      || tetrominoList.first.state == TetrominoState.moveless) {
      if (nextTetromino != null) {
        tetrominoList.insert(0, Tetromino(nextTetromino!));
        add(tetrominoList.first);
        remove(nextTetromino!);
      }
      _newTetromino();
    }
  }

  void _initBorders() {
    final firstBlock = blockObjects.first;
    final lastBlock = blockObjects.last;
    borders.add(firstBlock.y);
    borders.add(lastBlock.y);
    borders.add(firstBlock.x);
    borders.add(lastBlock.x);
  }

  void _initButtons() {
    final buttonObjList = _backgroundScreen.tileMap.getLayer<ObjectGroup>("Button")!.objects;

    List<PositionComponent> buttons = [];
    buttons.add(RedirectionButton(
        size: buttonObjList[1].size,
        position: buttonObjList[1].position,
        moveCommand: MoveCommand.left,
    ));
    buttons.add(RedirectionButton(
        size: buttonObjList[3].size,
        position: buttonObjList[3].position,
        moveCommand: MoveCommand.right,
    ));
    buttons.add(StateCtrlButton(
        size: buttonObjList[0].size,
        position: buttonObjList[0].position,
        func: rotateTetro,
    ));
    buttons.add(StateCtrlButton(
        size: buttonObjList[2].size,
        position: buttonObjList[2].position,
        func: speedUpTetro,
    ));

    buttons.add(StateCtrlButton(
        size: buttonObjList[4].size,
        position: buttonObjList[4].position,
        func: changeRunningState,
    ));
    buttons.add(StateCtrlButton(
        size: buttonObjList[5].size,
        position: buttonObjList[5].position,
        func: resetGame,
    ));

    addAll(buttons);
  }

  void _initScore() {
    final textObject = _backgroundScreen.tileMap.getLayer<ObjectGroup>("Score")!.objects.first;
    scoreComponent = Score(
      size: textObject.size,
      position: textObject.position,
    );

    add(scoreComponent);
  }

  void _newTetromino() {
    final tetroType = _getNewBlock();

    nextTetromino = DisplayTetromino(
      tetroType: tetroType,
      blockImage: _blockImage(tetroType),
    );

    add(nextTetromino!);
  }

  // When there're lines filled with blocks, clear these lines and make other blocks down.
  void checkLines() {
    _running = false;

    // Used to avoid the disturbance of empty lines that were not
    // added to newEmulator for the check of item numbers.
    int? emptyLineNum;

    List<int> fullLines = [];
    List<int> newEmulator = [];

    blocksBeRemoved.clear();

    for (var i = 199; i >= 0; i -= 10) {
      List<int> temp = [];
      var emptyLine = true;
      var hasEmptyBlock = false;

      for (var j = i; j > i - 10; j--) {
        if (tetrisEmulator[j] == 0) {
          if (!hasEmptyBlock) hasEmptyBlock = true;
        } else if (emptyLine) {
          emptyLine = false;
        }

        temp.insert(0, tetrisEmulator[j]);
      }

      if (!hasEmptyBlock) {
        fullLines.add(i - 10);
        blocksBeRemoved.addAll(List.generate(10, (index) => i - index));
        continue;
      }
      // When noticing that current line is an empty line, return current line number.
      if (emptyLine) {
        emptyLineNum = (i + 1) ~/ 10;
        break;
      }

      newEmulator.insertAll(0, temp);
    }

    var remainingItems = emptyLineNum != null
    ? newEmulator.length + emptyLineNum * 10
    : newEmulator.length;

    // Avoid extra cost.
    if (remainingItems == 200) {
      if (blocksBeRemoved.isNotEmpty) blocksBeRemoved.clear();
      _running = true;
      return;
    }

    final List<int> emptyBlocks = List.filled(
      200 - newEmulator.length,
      0
    );

    removedLines = fullLines;
    tetrisEmulator = [...emptyBlocks, ...newEmulator];
    scoreComponent.increase(fullLines.length);

    _running = true;
  }

  void removeEmptyTetro(Tetromino object) {
    remove(object);
    tetrominoList.remove(object);
  }

  // NOTE: When `init` is null, `positions` must be non-null.
  // When the movement is illegal, returning null.
  List<int>? newEmuPosition({
      int? init,
      int style = 0,
      double x = 0,
      double y = 0,
      List<int>? positions,
      required String tetroType,
  }) {
    List<int> temp = [];

    if (init != null) {
      for (final e in tetrominoMap[tetroType]![style]) {
        final newPosition = makeEmuPos(
          init,
          x: e.x,
          y: e.y
        );

        if (newPosition == null) return null;

        temp.add(newPosition);
      }

      return temp;
    }

    temp = List.from(positions!);
    for (var i = 0; i < 4; i++) {
      final newPosition = makeEmuPos(temp[i], x: x, y: y);
      if (newPosition == null) return null;
      temp[i] = newPosition;
    }

    return temp;
  }

  // Pause the game or not.
  void changeRunningState() {
    if (_running) {
      _running = false;
      tetrominoList.first.moveLock = true;
    } else {
      _running = true;
      tetrominoList.first.moveLock = false;
    }
  }

  void resetGame() {
    if (!_initialized) {
      _running = true;
      _initialized = true;
      return;
    }

    _running = false;

    for (final tetro in tetrominoList) {
      if (!tetro.isRemoved) remove(tetro);
    }
    scoreComponent.reset();

    if (nextTetromino != null
      && !nextTetromino!.isRemoved) remove(nextTetromino!);

    removedLines.clear();
    blocksBeRemoved.clear();

    nextTetromino = null;
    tetrominoList.clear();
    tetrisEmulator = List.filled(200, 0, growable: true);
    _running = true;
  }

  void speedUpTetro() {
    if (!_running) return;

    final movingTetro = tetrominoList.first;
    if (movingTetro.moveLock == true
      || movingTetro.state == TetrominoState.moveless) return;

    // Let the blocks move down twice continuously.
    movingTetro.moveLock = true;
    movingTetro.delayTime = 0;
    movingTetro.updateFalling(0);
    movingTetro.delayTime = 0;
    movingTetro.moveLock = false;
  }

  void rotateTetro() {
    if (!_running) return;

    final movingTetro = tetrominoList.first;
    if (movingTetro.moveLock
      || movingTetro.state == TetrominoState.moveless) return;

    movingTetro.rotateBlocks();
  }

  Future<void> storeCurrentScore() async {
    await storeNewScore(scoreComponent.score);
  }
}

String _blockImage(String block) {
  return blockImages[block]!;
}

String _getNewBlock() {
  return blockTypes[Random().nextInt(7)]!;
}

// NOTE: When the movement is illegal, returning null.
int? makeEmuPos(int idx, {double x = 0, double y = 0}) {
  var lineBeforeHorizontal = _calcLineNum(idx);
  idx += x.toInt();

  if (lineBeforeHorizontal != _calcLineNum(idx)) return null;

  idx += 10 * y.toInt();

  if (idx < 0 || idx > 199) return null;

  return idx;
}

int _calcLineNum(int idx) {
  var lineNum = (idx + 1) / 10;
  final lineLength = lineNum.toInt();

  if (lineNum - lineLength == 0) {
    lineNum--;
  }

  return lineNum.toInt();
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
