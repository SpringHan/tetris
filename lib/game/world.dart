import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';

import './tetromino.dart';
import './block.dart';
import './button.dart';

class Screen extends World {
  late TiledComponent backgroundScreen;
  late List<TiledObject> blockObjects;
  final List<TiledObject> nextBlockList = [];
  final List<int> tetrisEmulator = List.filled(200, 0);

  double delayTime = 0.5;
  int currentBlocks = 0;
  int blocksFinished = 0;       // The number of blocks which finished current dropping.
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

  @override
  void update(double dt) {
    if (delayTime == 0) {
      delayTime = 0.5;
    } else {
      delayTime -= dt;
      if (delayTime < 0) delayTime = 0;
    }

    super.update(dt);
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

  void generateBlock() {
    final newBlock = _getNewBlock();
  }

  void resetAttris() {
  }
}

String _blockImage(String block) {
  return blockImages[block]!;
}

String _getNewBlock() {
  return blockTypes[Random().nextInt(7)]!;
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
