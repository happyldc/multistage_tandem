# multistage_tandem

## 可自定义的多级联动Widget
 * 支持自定义联动级别
 * 支持自定义显示的样式
 * 支持多级联动修改

## 开始
在项目中依赖
~~~yaml
dependencies
 multistage_tandem:
    git:
      url: https://github.com/happyldc/multistage_tandem.git

~~~
## 使用方法
Import multistage_tandem.dart

~~~dart
import 'package:multistage_tandem/multistage_tandem.dart';
~~~
MultistageTandem 是一个有状态的wideget,故可以在和普通的Widget 一样使用，
使用MultistageTandem 必须传入 BaseHandler 的对象，实现联动级别自定义，显示样式，均由BaseHandler实现。
~~~~dart
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
~~~~

DEMO

**自定义四级省/市/区/乡镇城市 选择器 **
~~~~dart
class CityPickHandlerForVertical extends BaseHandler<AddressEntity> {

 List<String> stageList = ["省份", "城市", "区/县", "乡/镇"];
  ValueChanged<List<T>> onCompleted;
  CityPickHandlerForVertical({this.onCompleted});

 @override
  bool isLastStage(int curStageIndex, T t) {
    //限制当前最多联动级别为stageList的长度
    return curStageIndex >= stageList.length - 1;
  }
  @override
  Widget bodyItemBuild(BuildContext context, AddressEntity t,
      {bool isSelected = false}) {
    //自定义选项视图
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        "${t.name}",
        style: TextStyle(color: isSelected ? Colors.amber : Colors.black),
      ),
      height: 48,
      alignment: Alignment.centerLeft,
    );
  }

  @override
  Widget bodyLayout(BuildContext context, int stageIndex,
      List<AddressEntity> dataList, onItemSelected,
      {AddressEntity selectedItem}) {
      //自定义选项的列表视图
    return Container(
      child: ListView.builder(
          itemCount: dataList?.length ?? 0,
          itemBuilder: (c, index) {
            return InkWell(
              child: bodyItemBuild(c, dataList[index],
                  isSelected: isTheSameItem(selectedItem, dataList[index])),
              onTap: () {
                onItemSelected(stageIndex, dataList[index]);
              },
            );
          }),
    );
  }

  @override
  Widget headerItemBuild(BuildContext context, int stageIndex, AddressEntity t,
      {bool isSelected = false}) {
      //自定头部列表项视图
    if (t != null) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          "$t",
          style: TextStyle(
              fontSize: 16, color: isSelected ? Colors.amber : Colors.black),
        ),
        height: 48,
        alignment: Alignment.centerLeft,
      );
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      key: Key(DateTime.now().toIso8601String()),
      child: Row(
        children: <Widget>[
          Text(
            "请选择${stageList[stageIndex]}",
            style: TextStyle(color: Colors.blue),
          )
        ],
      ),
      height: 48,
      alignment: Alignment.centerLeft,
    );
  }

  @override
  Widget headerLayout(BuildContext context, List<Widget> titles) {
  //自定义头部布局视图
    return Container(
      alignment: Alignment.topLeft,
      child: Column(
        children: titles,
      ),
    );
  }

  @override
  bool isTheSameItem(AddressEntity item1, AddressEntity item2) {
    return item1?.name == item2?.name;
  }

  @override
  void onComplete(List<AddressEntity> result) {
  //当最后一级选中时回调
    if (this.onCompleted != null) {
      this.onCompleted(result);
    }
  }

  List<AddressEntity> addressList = [];

  @override
  Future<List<AddressEntity>> queryData(
      int stageIndex, AddressEntity lastStageValue) async {
    if (addressList.length == 0) {
      addressList = await loadAddressList();
    }
    if (lastStageValue == null) {
      return addressList;
    } else {
      for (int i = 0; i < addressList.length; i++) {
        List<AddressEntity> result =
            lookChildren(addressList[i], lastStageValue);
        if (result != null) {
          return result;
        }
      }
    }
    return null;
  }

  List<AddressEntity> lookChildren(AddressEntity item, AddressEntity child) {
    if (item.code == child.code) {
      return child.children;
    } else if (item.children != null) {
      for (int i = 0; i < item.children.length; i++) {
        List<AddressEntity> result = lookChildren(item.children[i], child);
        if (result != null) {
          return result;
        }
      }
      return null;
    } else {
      return null;
    }
  }

  static Future<List<AddressEntity>> loadAddressList() async {
    List<AddressEntity> records = new List<AddressEntity>();
    try {
      String jsonStr = await rootBundle.loadString("assets/datas/pcas.json");
      List<dynamic> _dataMap = json.decode(jsonStr);
      List recordsMap = _dataMap;
      records = recordsMap.map((item) {
        return AddressEntity.fromJson(item);
      }).toList();
    } catch (e) {
      print(e);
    }
    return records;
  }
}

~~~~




