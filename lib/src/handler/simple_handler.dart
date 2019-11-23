import 'package:flutter/material.dart';

import 'package:multistage_tandem/src/handler/base_handler.dart';


abstract class SimpleHandler<T> extends BaseHandler<T> {
  List<String> stageList = [];
  ValueChanged<List<T>> onCompleted;

  SimpleHandler(this.stageList, {this.onCompleted});

  @override
  bool isLastStage(int curStageIndex, T t) {
    return curStageIndex >= stageList.length - 1;
  }
}
