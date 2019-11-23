import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:multistage_tandem/multistage_tandem.dart';
import 'package:multistage_tandem_example/city_pick/city_pick.dart';
class CityPickHandlerForHorizontal extends SimpleHandler<AddressEntity>{
  CityPickHandlerForHorizontal({ValueChanged<List<AddressEntity>> onCompleted})
      : super(["省份", "城市", "区/县", "乡/镇"], onCompleted: onCompleted);
  @override
  Widget bodyItemBuild(BuildContext context, AddressEntity t, {bool isSelected = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Text("${t.name}",style: TextStyle(color: isSelected?Colors.amber:Colors.black),),
      height: 48,
      alignment: Alignment.centerLeft,
    );
  }

  @override
  Widget bodyLayout(BuildContext context, int stageIndex, List<AddressEntity> dataList, onItemSelected, {AddressEntity selectedItem}) {
    return Container(
      child: ListView.builder(
          itemCount: dataList?.length ?? 0,
          itemBuilder: (c, index) {
            return InkWell(
              child: bodyItemBuild(c, dataList[index],isSelected: isTheSameItem(selectedItem, dataList[index]) ),
              onTap: () {
                onItemSelected(stageIndex,dataList[index]);
              },
            );
          }),
    );
  }

  @override
  Widget headerItemBuild(BuildContext context, int stageIndex, AddressEntity t, {bool isSelected = false}) {
        if (t != null) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          "$t",
          style: TextStyle(fontSize: 16,color:isSelected?Colors.amber:Colors.black),
        ),
        height: 48,
        alignment: Alignment.centerLeft,
      );
    }
    return Container(
//        assets/images/add_icon_del.png
      padding: EdgeInsets.symmetric(horizontal: 16),
      key: Key(DateTime.now().toIso8601String()),
      child: Row(
        children: <Widget>[
          Text(
            "${stageList[stageIndex]}",
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
    return Container(
      alignment: Alignment.topLeft,
      child: Row(
        children: titles,
      ),
    );
  }

  @override
  bool isTheSameItem(AddressEntity item1, AddressEntity item2) {
    return item1?.name==item2?.name;
  }

  @override
  void onComplete(List<AddressEntity> result) {
    if(this.onCompleted!=null){
      this.onCompleted(result);
    }
  }

  List<AddressEntity> addressList = [];
  @override
  Future<List<AddressEntity>> queryData(int stageIndex, AddressEntity lastStageValue) async{
    if (addressList.length == 0) {
      addressList = await loadAddressList();
    }
    if (lastStageValue == null) {
      return addressList;
    } else {
      for (int i = 0; i < addressList.length; i++) {
        List<AddressEntity> result = lookChildren(addressList[i], lastStageValue);
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