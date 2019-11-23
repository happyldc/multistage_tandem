import 'package:flutter/material.dart';
import 'package:multistage_tandem_example/city_pick/handler/city_pick_handler_for_horizontal.dart';

import 'city_pick/city_pick.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  String text = "";
  List<AddressEntity> hasChoiceList = [];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('多级联动Demo'),
        ),
        body: Center(
          child: Builder(builder: (c){
            return Column(
              children: <Widget>[
                Container(height: 40,),
                Text("$text"),
                Container(height: 40,),
                FlatButton(
                    onPressed: () async {
                      List<AddressEntity> result =
                      await showCityPickersVertical(c, hasChoiceList);
                      if (result != null) {
                        hasChoiceList = result;
                        showResult();
                      }
                    },
                    child: Text("选择城市(vertical)")),
                FlatButton(
                    onPressed: () async {
                      List<AddressEntity> result =
                      await showCityPickersHorizontal(c, hasChoiceList);
                      if (result != null) {
                        hasChoiceList = result;
                        showResult();
                      }
                    },
                    child: Text("选择城市(horizontal)")),
                FlatButton(
                    onPressed: () async {
                      if(hasChoiceList.isNotEmpty){
                      hasChoiceList.removeLast();
                      }
                      showResult();
                    },
                    child: Text("清空"))
              ],
            );
          }),
        ),
      ),
    );
  }

  void showResult() {
    String tempTxt = "";
    hasChoiceList.forEach((item) {
      tempTxt += item.name;
    });
    setState(() {
      text = tempTxt;
    });
    setState(() {

    });
  }

  static Future<List<AddressEntity>> showCityPickersVertical(
      context, List<AddressEntity> choiceValues) {
    return showModalBottomSheet<List<AddressEntity>>(
        context: context,
//        shape: RoundedRectangleBorder(
//            borderRadius: BorderRadius.vertical(top: Radius.circular(8))),
        builder: (context) {
          return Container(

            child: MultistageTandem<AddressEntity>(
                CityPickHandlerForVertical(onCompleted: (list) {
              Navigator.pop(context, list);
            }),initChoiceValues: choiceValues,),
          );
        });
  }
  static Future<List<AddressEntity>> showCityPickersHorizontal(
      context, List<AddressEntity> choiceValues) {
    return showModalBottomSheet<List<AddressEntity>>(
        context: context,
//        shape: RoundedRectangleBorder(
//            borderRadius: BorderRadius.vertical(top: Radius.circular(8))),
        builder: (context) {
          return Container(

            child: MultistageTandem<AddressEntity>(
              CityPickHandlerForHorizontal(onCompleted: (list) {
                Navigator.pop(context, list);
              }),initChoiceValues: choiceValues,),
          );
        });
  }
}
