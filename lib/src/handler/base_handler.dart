import 'package:flutter/material.dart';

///多级联动核心接口，
abstract class BaseHandler<T> {
  ///当前curStageIndex最后一级  t 当前选中的项，当t==null时为第一级
  bool isLastStage(int stageIndex, T stageValue);
  ///判断ITEM是否为同一对象
bool isTheSameItem(T item1,T item2);
  ///请求该级的可选的数据 支持异步加载
  Future<List<T>> queryData(int stageIndex, T lastStageValue);

  ///完成
  ///[result] 已选中的结果
  void onComplete(List<T> result);

  ///头部布局
  Widget headerLayout(BuildContext context,List<Widget> titles);

  ///创建头部布局列表项视图
  ///[stageIndex] ///第stageIndex 级， t 如果该级已选中 则t 有值  如t==null 返回 请选择省份  不为null 返回福建省
  Widget headerItemBuild(BuildContext context,int stageIndex, T t,{bool isSelected=false});

  ///内容布局,即选项试图
  ///[dataList] 内容视图的数据源
  ///[onItemSelected] 数据源中每一项视图点击时回调
  Widget bodyLayout(BuildContext context,int stageIndex,List<T> dataList, Function(int stageIndex,T t) onItemSelected,{T  selectedItem});

  ///创建列表项的视图
  Widget bodyItemBuild(BuildContext context,T t,{bool isSelected=false});
}

