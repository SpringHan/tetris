import 'package:flutter/material.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';

import './game/game.dart';
import './components/main_page.dart';

void main() {
  // WidgetsFlutterBinding.ensureInitialized();
  // Flame.device.fullScreen();
  // Flame.device.setPortrait();

  // final game = TetrisGame();
  runApp(const MainPage());
}
