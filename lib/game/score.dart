import 'dart:async';

import 'package:flame/text.dart';
import 'package:flame/layout.dart';
import 'package:flame/components.dart';

class Score extends PositionComponent {
  Score({
      required super.size,
      required super.position,
  });

  late final AlignComponent component;

  int prev = 0;
  int score = 0;

  @override
  FutureOr<void> onLoad() async {
    final component = AlignComponent(
      alignment: Anchor.centerRight,
      child: TextComponent(
        textRenderer: TextPaint(
          style: const TextStyle(
            fontSize: 150,
          ),
        ),
        text: score.toString(),
      ),
    );

    add(component);
  }

  @override
  void update(double dt) {
    if (prev != score) {
      prev = score;
      final child = component.child as TextComponent;
      child.text = score.toString();
      // component.update(dt);
    }
  }

  @override
  void onRemove() {
    remove(component);
  }

  void increase() {
    score++;
  }

  void reset() {
    score = 0;
  }
}
