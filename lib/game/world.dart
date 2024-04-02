import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';

import './tetromino.dart';
import './button.dart';
import './display_tetro.dart';
import './block.dart' show tetrominoMap;

class Screen extends World {
  // Basic variables.
  bool _running = false;
  bool _initialized = false;
  late final List<TiledObject> blockObjects;
  late final TiledComponent _backgroundScreen;
  late final List<TiledObject> nextBlockObjects;
  List<int> tetrisEmulator = List.filled(200, 0, growable: true);

  (int, int)? moveLines; // Lines to move down. Used after clearing full lines.
  List<int> blocksBeRemoved = []; // The idx of blocks to be removed.

  // The number of tetromino which finished current dropping.
  int tetrominoFinished = 0;

  final List<double> borders = [];
  final List<Tetromino> tetrominoList = [];
  DisplayTetromino? nextTetromino;

  bool toRotate = false;
  double delayLimit = 0.5;
  MoveCommand moveCommand = MoveCommand.none;

  @override
  FutureOr<void> onLoad() async {
    _backgroundScreen = await TiledComponent.load("Main.tmx", Vector2.all(16));

    blockObjects = _backgroundScreen.tileMap.getLayer<ObjectGroup>("Block")!.objects;
    nextBlockObjects = _backgroundScreen.tileMap.getLayer<ObjectGroup>("NextBlock")!.objects;

    _initBorders();
    _initButtons();

    add(_backgroundScreen);
  }

  @override
  void update(double dt) {
    if (!_running) return;

    if (tetrominoFinished == tetrominoList.length) {
      if (nextTetromino != null) {
        tetrominoList.add(Tetromino(nextTetromino!));
        add(tetrominoList.last);
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
    // Used to avoid the disturbance of empty lines that were not
    // added to newEmulator for the check of item numbers.
    int? emptyLineNum;

    int? splitItem;
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
        splitItem ??= i - 10;
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
    if (remainingItems == 200) return;

    moveLines = (splitItem!, 20 - remainingItems ~/ 10);

    final List<int> emptyBlocks = List.filled(
      200 - newEmulator.length,
      0
    );
    tetrisEmulator = [...emptyBlocks, ...newEmulator];
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

    // if (init != null) {
    //   temp.add(init);
    // } else {
    //   temp.add(makeEmuPos(positions![0], x: x, y: y));
    // }

    // for (final e in tetrominoMap[tetroType]![tetroStyle]) {
    //   if (e == Vector2(0, 0)) continue;
    //   temp.add(makeEmuPos(
    //       temp[0],
    //       x: e.x,
    //       y: e.y
    //   ));
    // }

    // return temp;
  }

  // Pause the game or not.
  void changeRunningState() {
    if (_running) {
      _running = false;
      tetrominoList.last.moveLock = true;
    } else {
      _running = true;
      tetrominoList.last.moveLock = false;
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

    if (nextTetromino != null
      && !nextTetromino!.isRemoved) remove(nextTetromino!);

    moveLines = null;
    blocksBeRemoved.clear();

    delayLimit = 0.5;
    nextTetromino = null;
    tetrominoFinished = 0;
    tetrominoList.clear();
    moveCommand = MoveCommand.none;
    tetrisEmulator = List.filled(200, 0, growable: true);
    _running = true;
  }

  void speedUpTetro() {
    delayLimit = 0;
  }

  void restoreSpeed() {
    if (delayLimit != 0.5) delayLimit = 0.5;
  }

  void rotateTetro() {
    toRotate = true;
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
  // idx += x.toInt() + 10 * y.toInt();
  if ((idx + 1) % 10 == 0 && x > 0
    || idx % 10 == 0 && x < 0) return null;

  idx += x.toInt() + 10 * y.toInt();

  if (idx > 199) return null;

  return idx;
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
