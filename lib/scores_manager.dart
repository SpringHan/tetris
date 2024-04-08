import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

Future<void> storeNewScore(int score) async {
  final cacheDirectory = await getExternalStorageDirectory();
  final scoreFile = "${cacheDirectory!.path}/scores.txt";

  final file = File(scoreFile);
  String content;

  if (!file.existsSync()) await file.create();
  
  content = "$score";
  await file.writeAsString(content);
}

Future<int> fetchScore() async {
  final cacheDirectory = await getExternalStorageDirectory();
  final scoreFile = "${cacheDirectory!.path}/scores.txt";

  final file = File(scoreFile);

  if (!file.existsSync()) {
    await file.create();
    return 0;
  }

  final content = await file.readAsString();

  return int.parse(content);
}
