import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';

import './tetromino.dart';
import './button.dart';

class Screen extends World {
  // Basic variables.
  late TiledComponent backgroundScreen;
  late List<TiledObject> blockObjects;
  List<int> tetrisEmulator = List.filled(200, 0, growable: true);

  // TODO: Init this.
  final List<TiledObject> nextBlockObjects = [];

  (int, int)? moveLines;               // Lines to move down. Used after clearing full lines.
  int currentBlocks = 0;
  int blocksFinished = 0;       // The number of blocks which finished current dropping.
  List<int> blocksBeRemoved = []; // The idx of blocks to be removed.
  final List<double> borders = [];
  final List<Tetromino> tetrominoList = [];
  MoveCommand moveCommand = MoveCommand.none;

  @override
  FutureOr<void> onLoad() async {
    backgroundScreen = await TiledComponent.load("Main.tmx", Vector2.all(16));

    blockObjects = backgroundScreen.tileMap.getLayer<ObjectGroup>("Block")!.objects;
    _initBorders();
    _initButtons();

    final newBlock = _getNewBlock();
    final test = Tetromino(
      tetroType: newBlock,
      blockImage: _blockImage(newBlock),
    );

    addAll([
        backgroundScreen,
        test
    ]);
    super.onLoad();
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
    final buttonList = backgroundScreen.tileMap.getLayer<ObjectGroup>("Button")!.objects;

    List<PositionComponent> buttons = [];
    buttons.add(RedirectionButton(
        size: buttonList[1].size,
        position: buttonList[1].position,
        moveCommand: MoveCommand.left,
    ));
    buttons.add(RedirectionButton(
        size: buttonList[3].size,
        position: buttonList[3].position,
        moveCommand: MoveCommand.right,
    ));

    addAll(buttons);
  }

  // TODO: This function should even be executed when creating a tetromino.
  bool noObstacle(List<int> positions) {
    for (final p in positions) {
      if (tetrisEmulator[p] == 1) return false;
    }

    return true;
  }

  // TODO: Next
  void updateEmulator(List<int> positions) {
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
          if (hasEmptyBlock) hasEmptyBlock = true;
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
}

String _blockImage(String block) {
  return blockImages[block]!;
}

String _getNewBlock() {
  return blockTypes[Random().nextInt(7)]!;
}

// NOTE: As the check of the occupation of blocks is executed
// after boundary check, there's no need to care about overflow here.
int makeEmuPos(int idx, {double x = 0, double y = 0}) {
  idx += x.toInt() + 10 * y.toInt();
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
