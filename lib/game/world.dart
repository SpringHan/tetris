import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';

import './block.dart';

class Screen extends World {
  late TiledComponent backgroundScreen;
  // final BlockSprite blockSprite = BlockSprite(priority: 1);

  @override
  FutureOr<void> onLoad() async {
    backgroundScreen = await TiledComponent.load("Main.tmx", Vector2.all(16));

    final blockLayer = backgroundScreen.tileMap.getLayer<ObjectGroup>("Block")!;
    final test = blockLayer.objects.asMap()[0]!;
    final blockSprite = BlockSprite(position: Vector2(test.x, test.y));

    addAll([backgroundScreen, blockSprite]);
    return super.onLoad();
  }
}
