import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

Future<void> storeNewScore(int score) async {
  final cacheDirectory = await getExternalStorageDirectory();
  final scoreFile = "${cacheDirectory!.path}/scores.txt";

  final file = File(scoreFile);
  String content;

  if (!file.existsSync()) {
    await file.create();
    content = "$score";
  } else {
    content = await file.readAsString();
    final scoreList = content.split("\n");
    scoreList.sort((a, b) => b.toInt().compareTo(a.toInt()));
    content = scoreList.join("\n");
  }

  await file.writeAsString(content);
}

Future<List<int>> fetchScores() async {
  final cacheDirectory = await getExternalStorageDirectory();
  final scoreFile = "${cacheDirectory!.path}/scores.txt";

  final file = File(scoreFile);

  if (!file.existsSync()) {
    await file.create();
    return [];
  }

  final content = await file.readAsString();
  final stringList = content.split("\n");

  final List<int> scores = [];
  for (final s in stringList) {
    scores.add(s.toInt());
  }

  return scores;
}

extension ToInt on String {
  int toInt() {
    return int.parse(this);
  }
}
