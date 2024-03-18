import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';

class Screen extends World {
  late TiledComponent backgroundScreen;

  @override
  FutureOr<void> onLoad() async {
    backgroundScreen = await TiledComponent.load("Main.tmx", Vector2.all(16));

    add(backgroundScreen);
    return super.onLoad();
  }
}
