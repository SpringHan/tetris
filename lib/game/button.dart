import 'package:flame/components.dart';
import 'package:flame/events.dart';

import './world.dart';
import './tetromino.dart' show MoveCommand;

class RedirectionButton extends PositionComponent
with HasWorldReference<Screen>, TapCallbacks {
  RedirectionButton({
      required super.size,
      required super.position,
      required this.moveCommand,
  });

  final MoveCommand moveCommand;

  @override
  void onTapDown(TapDownEvent event) {
    world.moveCommand = moveCommand;
  }
}

class StateCtrlButton extends PositionComponent
with HasWorldReference<Screen>, TapCallbacks {
  StateCtrlButton({
      required super.size,
      required super.position,
      required this.func,
  });

  final void Function() func;

  @override
  void onTapDown(TapDownEvent event) {
    func();
  }
}
