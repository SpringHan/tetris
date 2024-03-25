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

  final List<BlockSprite> blocks = [];

  @override
  FutureOr<void> onLoad() async {
    // TODO: Only generate tetromino from this class.
  }
}
