import 'dart:async';

import 'package:flame/components.dart';

import './world.dart';
import './block.dart';

class DisplayTetromino extends Component
with HasWorldReference<Screen> {
  DisplayTetromino({
      required this.tetroType,
      required this.blockImage,
  });

  final String tetroType;
  final String blockImage;

  List<int> positionInEmu = [];
  final List<BlockSprite> blocks = [];

  @override
  FutureOr<void> onLoad() async {
    final targetPosition = Vector2(
      world.nextBlockObjects[1].x,
      world.nextBlockObjects[1].y
    );
    final relativePositions = tetrominoMap[tetroType]!;

    positionInEmu = world.newEmuPosition(
      init: 1,
      tetroType: tetroType
    );

    for (final p in relativePositions) {
      blocks.add(BlockSprite(
          blockImage: blockImage,
          position: targetPosition + p * 64,
      ));
    }

    addAll(blocks);
  }

  @override
  void onRemove() {
    removeAll(blocks);
  }
}
