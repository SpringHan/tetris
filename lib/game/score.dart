import 'dart:async';

import 'package:flame/text.dart';
import 'package:flame/layout.dart';
import 'package:flame/components.dart';

base class Score extends PositionComponent {
  Score({
      required super.size,
      required super.position,
  });

  late final AlignComponent component;

  int prev = 0;
  int score = 0;

  @override
  FutureOr<void> onLoad() async {
    component = AlignComponent(
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
    }
  }

  @override
  void onRemove() {
    remove(component);
  }
}

final class CurrentScore extends Score {
  CurrentScore({
      required super.size,
      required super.position,
  });

  double limitTime = 0.5;

  void increase(int scores) {
    score += scores;

    if (limitTime == 0) return;
    limitTime = 0.5 - (score ~/ 5) * 0.03;
    if (limitTime < 0) limitTime = 0;
  }

  void reset() {
    score = 0;
    limitTime = 0.5;
  }
}

final class MaxScore extends Score with HasVisibility {
  MaxScore({
      required super.size,
      required super.position,
      required int score,
  }) {
    super.score = score;
    isVisible = false;
  }

  void setScore(int score) {
    super.score = score;
  }

  void show(bool show) {
    isVisible = show;
  }
}
