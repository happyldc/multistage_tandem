import 'package:flutter/material.dart';
import 'package:multistage_tandem/src/handler/base_handler.dart';
import 'package:multistage_tandem/multistage_tandem.dart';

class MultistageTandem<T> extends StatefulWidget {
  ///初始化已选中的值 用于上次选择好后保存起来
  List<T> initChoiceValues;
  BaseHandler<T> multiStatgeHandler;
  Widget Function() showLoading;
  Widget Function({String msg, VoidCallback onPressed}) showFaild;
  Widget Function({String msg, VoidCallback onPressed}) showEmpty;

  MultistageTandem(this.multiStatgeHandler,
      {this.initChoiceValues,
      this.showLoading,
      this.showFaild,
      this.showEmpty}) {
    if (showLoading == null) {
      this.showLoading = ({String msg}) {
        return Center(
          child: Text(msg ?? "加载中..."),
        );
      };
    }
    if (showFaild == null) {
      this.showFaild = ({String msg, VoidCallback onPressed}) {
        return InkWell(
          child: Center(
            child: Text(msg ?? "加载失败..."),
          ),
          onTap: onPressed,
        );
      };
    }
    if (showFaild == null) {
      this.showFaild = ({String msg, VoidCallback onPressed}) {
        return InkWell(
          child: Center(
            child: Text(msg ?? "加载失败..."),
          ),
          onTap: onPressed,
        );
      };
    }
    if (showEmpty == null) {
      this.showEmpty = ({String msg, VoidCallback onPressed}) {
        return InkWell(
          child: Center(
            child: Text(msg ?? "没有可选项..."),
          ),
          onTap: onPressed,
        );
      };
    }
  }

  @override
  _MultistageTandemState createState() => _MultistageTandemState<T>();
}

class _MultistageTandemState<T> extends State<MultistageTandem> {
  LoadState _loadingState = LoadState.loading;

  @override
  void initState() {
    super.initState();
    if (widget.initChoiceValues != null && widget.initChoiceValues.isNotEmpty) {
      for (int i = 0; i < widget.initChoiceValues.length; i++) {
        T value = widget.initChoiceValues[i];
        HeaderEntity<T> headerEntity = headerStack.atNotEmpty(i);
        headerEntity.stageValue = value;
        headerStack.addOrModify(i, headerEntity);
        headerStack.stageIndex = i;
      }
      headerStack.isModify = false;
    }

    initNextHeader();

    ///最近步骤的索引和值
    int lastStageIndex = headerStack.stageIndex;

    T lastStageValue;

    if (headerStack.stageIndex == 0) {
      lastStageValue = null;
    } else {
      if (widget.multiStatgeHandler.isLastStage(headerStack.stageIndex,
          headerStack.atNotEmpty(headerStack.stageIndex).stageValue)) {
        //最后一级 为选项可显示
        lastStageValue =
            headerStack.atNotEmpty(headerStack.stageIndex - 1).stageValue;
        lastStageIndex = headerStack.stageIndex;
      } else {
        ///非最后一级
        lastStageValue =
            headerStack.atNotEmpty(headerStack.stageIndex).stageValue;
        headerStack.stageIndex++;
        lastStageIndex = headerStack.stageIndex;
      }
    }
    loadData(lastStageIndex, lastStageValue);
  }

  List<T> stageDataList = [];

  void loadData(int stageIndex, T lastValue) async {
    _loadingState = LoadState.loading;
    setState(() {});

    try {
      List<T> tempData =
          await widget.multiStatgeHandler.queryData(stageIndex, lastValue);
      if (tempData == null) {
        tempData = [];
      }
      stageDataList.clear();
      stageDataList.addAll(tempData);
      if (stageDataList.isEmpty) {
        _loadingState = LoadState.empty;
      } else {
        _loadingState = LoadState.success;
      }
      setState(() {});
    } catch (e) {
      _loadingState = LoadState.faild;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          buildStageContainer(),
          Container(
            height: 8,
          ),
          Divider(
            height: 1,
          ),
          Expanded(child: buildStageContentContainer()),
        ],
      ),
    );
  }

  HeaderStack<T> headerStack = new HeaderStack();

  initNextHeader() {
    List<HeaderEntity<T>> headerList = headerStack.toList();
    int len = headerList.length;
    HeaderEntity<T> lastStageValue;

    if (len == 0) {
      headerStack.addOrModify(0, headerStack.atNotEmpty(len));
    } else {
      lastStageValue = headerList[len - 1];
    }

    ///最后一级了
    if (!widget.multiStatgeHandler
        .isLastStage(len - 1, lastStageValue?.stageValue)) {
      headerStack.addOrModify(len, headerStack.atNotEmpty(len));
    }
  }

  buildStageContainer() {
    headerStack.toList().forEach((item) {
      HeaderEntity headerEntity = headerStack.atNotEmpty(item.stageIndex);
      headerEntity.widget = InkWell(
        child: widget.multiStatgeHandler.headerItemBuild(
            context, item.stageIndex, item.stageValue,
            isSelected: headerStack.isModify &&
                item.stageIndex == headerStack.stageIndex),
        onTap: () {
          headerStack.stageIndex = item.stageIndex;
          headerStack.isModify = true;
          loadData(item.stageIndex,
              headerStack.atNotEmpty(item.stageIndex - 1)?.stageValue);
        },
      );
      headerStack.addOrModify(item.stageIndex, headerEntity);
    });

    return Container(
      child: widget.multiStatgeHandler.headerLayout(
          context,
          headerStack.toList().map((item) {
            return item.widget;
          }).toList()),
    );
  }

  Widget buildStageContentContainer() {
    switch (_loadingState) {
      case LoadState.loading:
        return widget.showLoading();
        break;
      case LoadState.faild:
        return widget.showFaild(onPressed: () {
          reload();
        });
        break;
      case LoadState.success:
        return Container(
          child: widget.multiStatgeHandler.bodyLayout(
              context, headerStack.stageIndex, stageDataList, itemSelected,
              selectedItem:
                  headerStack.atNotEmpty(headerStack.stageIndex).stageValue),
        );
        break;
      case LoadState.empty:
        return widget.showEmpty(onPressed: () {
          reload();
        });
        break;
      default:
        return widget.showFaild(
            msg: "未知错误",
            onPressed: () {
              reload();
            });
        break;
    }
  }

  void reload() async {
    T lastValue = headerStack.stageIndex > 0
        ? headerStack.atNotEmpty(headerStack.stageIndex - 1).stageValue
        : null;
    _loadingState = LoadState.loading;
    setState(() {});
    loadData(headerStack.stageIndex, lastValue);
  }

  void itemSelected(int stageIndex, T t) async {
    HeaderEntity<T> headerEntity = headerStack.atNotEmpty(stageIndex);
    if (!widget.multiStatgeHandler.isTheSameItem(headerEntity.stageValue, t)) {
      //不同选项 移除stageIndex 之后的对象
      headerStack.removeAfterStageIndex();
    }

    headerEntity.stageValue = t;
    headerStack.addOrModify(stageIndex, headerEntity);
    initNextHeader();

    if (widget.multiStatgeHandler.isLastStage(headerStack.stageIndex, t)) {
      headerStack.isModify = false;
      setState(() {});
      widget.multiStatgeHandler.onComplete(headerStack.toList().map((item) {
        return item.stageValue;
      }).toList());

      return;
    }
    this.headerStack.stageIndex = this.headerStack.stageIndex + 1;

    setState(() {});
    loadData(this.headerStack.stageIndex, t);
  }
}

class HeaderStack<T> {
  ///当前级别
  int stageIndex = 0;

  ///header 点击时才有选中修改的效果
  bool isModify = true;

  ///[int] 为stage
  Map<int, HeaderEntity<T>> headerList = {};

  void addOrModify(int stageIndex, HeaderEntity<T> header) {
    if (headerList.containsKey(stageIndex)) {
      headerList[stageIndex].stageIndex = stageIndex;
      headerList[stageIndex].stageValue = header.stageValue;
      headerList[stageIndex].widget = header.widget;
    } else {
      headerList[stageIndex] = header;
    }
  }

  List<HeaderEntity<T>> toList() {
    List<HeaderEntity<T>> list = [];
    headerList.forEach((index, value) {
      list.add(value);
    });
    return list;
  }

  HeaderEntity<T> atNotEmpty(int stageIndex) {
    return headerList.containsKey(stageIndex)
        ? headerList[stageIndex]
        : new HeaderEntity<T>(stageIndex: stageIndex);
  }

  void removeAfterStageIndex() {
    int tempIndex = stageIndex + 1;
    HeaderEntity obj;
    while ((obj = headerList[tempIndex]) != null) {
      headerList.remove(tempIndex);
      tempIndex++;
    }
  }
}

class HeaderEntity<T> {
  ///级别索引
  int stageIndex;

  ///级别对应的值
  T stageValue;

  ///级别显示的组件
  Widget widget;

  HeaderEntity({this.stageIndex, this.stageValue, this.widget});
}
