import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';

import './game/game.dart';

void main() {
  Flame.device.fullScreen();
  Flame.device.setPortrait();

  final game = TetrisGame();
  runApp(GameWidget(game: kDebugMode ? game : TetrisGame()));
}
