import 'dart:async';

import 'package:flame/game.dart';
import 'package:flame/components.dart';

import './world.dart';

class TetrisGame extends FlameGame {
  late final CameraComponent cam;

  final backgroundScreen = Screen();

  @override
  FutureOr<void> onLoad() async {
    await images.loadAllImages();

    cam = CameraComponent.withFixedResolution(
      world: backgroundScreen,
      width: 1184,
      height: 1408
    );
    cam.viewfinder.anchor = Anchor.topLeft;

    addAll([cam, backgroundScreen]);

    return super.onLoad();
  }

  // @override
  // Color backgroundColor() {
  //   return const Color(0xFFFFFFFF);
  // }
}
