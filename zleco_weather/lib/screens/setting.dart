import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_dialogs/flutter_dialogs.dart';

class Setting extends StatefulWidget {
  const Setting({Key? key}) : super(key: key);

  @override
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //backgroundColor: Color(0xff75E6F7),  //appBar 투명색
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: Text('추가정보',
          style: TextStyle(
              fontFamily: 'tmon',
              fontSize: 20.0,
              color: Colors.black87
          ),
        ),
        leading: IconButton(
            icon: SvgPicture.asset(
              'assets/setting/Orion_angle-left-circle.svg',
              width: 30.0,
              height: 30.0,
            ),
            onPressed: () {
              Navigator.pop(context); //뒤로가기
            },
        ),
      ),
      body: ListView(
        children: [
          Divider(
            color: Colors.black38,
            thickness: 1,
          ),
          InkWell(
            onTap: (){
              _showDialog(context);
            },
            child: Container(
              padding: EdgeInsets.all(10),
              height: 40,
              child: Text('미세먼지/초미세먼지 등급 기준',
                style: TextStyle(
                    fontFamily: 'tmon',
                    fontSize: 15.0,
                    color: Colors.black87
                ),
              ),
            ),
          ),
          Divider(
            color: Colors.black38,
            thickness: 1,
          ),
          InkWell(
            onTap:(){
              Future.delayed(Duration.zero, (){
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => LicensePage()));
              });
            },
            child: Container(
              padding: EdgeInsets.all(10),
              height: 40,
              child: Text('오픈소스 라이선스',
                style: TextStyle(
                    fontFamily: 'tmon',
                    fontSize: 15.0,
                    color: Colors.black87
                ),
              ),
            ),
          ),
          Divider(
            color: Colors.black38,
            thickness: 1,
          )
        ],
      ),
    );
  }
}

void _showDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      // return object of type Dialog
      return AlertDialog(
        title: new Text("미세먼지 / 초미세먼지 등급 기준",
          style: TextStyle(
              fontFamily: 'tmon',
              fontSize: 20.0,
              color: Colors.black87
          ),
        ),
        content: SingleChildScrollView(
            child:
            new Text('''
미세먼지(PM-10)
   -좋음 0~30
   -보통 31~80
   -나쁨 81~150
   -매우나쁨 151 이상
            
초미세먼지(PM-25)
   -좋음 0~15
   -보통 16~35
   -나쁨 36~75
   -매우나쁨 76 이상
            
단위: ㎍/㎥
            
환경부 에어코리아 제공         
            ''',
              style: TextStyle(
                  fontSize: 20.0,
                  color: Colors.black87
              ),
            ),
        ),
        actions: <Widget>[
          new MaterialButton(
            child: new Text("닫기"),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0)
        )
      );
    },
  );
}