import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hiiidan_weather/data/network.dart';
import 'package:hiiidan_weather/screens/weather_screen.dart';
import 'package:intl/intl.dart';
import 'weather_screen.dart';
import 'package:hiiidan_weather/data/my_location.dart';
import 'package:http/http.dart' as http;

final String apiKey = FlutterConfig.get('apiKey');
final String kakaoApiKey = FlutterConfig.get('kakao_api');

class Loading extends StatefulWidget {
  const Loading({Key? key}) : super(key: key);

  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  String? baseTime;
  String? baseDate;
  String? baseDate_2am;
  String? baseTime_2am;
  String? currentBaseTime; //초단기 실황
  String? currentBaseDate;
  String? sswBaseTime; //초단기 예보
  String? sswBaseDate;

  int? xCoordinate;
  int? yCoordinate;
  double? userLati;
  double? userLongi;

  var now = DateTime.now();

  void initState(){
    super.initState();
    getLocation();
  }

  //오늘 날짜 20201109 형태로 리턴
  String getSystemTime(){
    return DateFormat("yyyyMMdd").format(now);
  }

  //어제 날짜 20201109 형태로 리턴
  String getYesterdayDate(){
    return DateFormat("yyyyMMdd").format(DateTime.now().subtract(Duration(days:1)));
  }

  void getLocation() async{
    MyLocation userLocation = MyLocation();
    await userLocation.getMyCurrentLocation(); //사용자의 현재 위치 불러올 때까지 대기

    xCoordinate = userLocation.currentX;  //x좌표
    yCoordinate = userLocation.currentY;  //y좌표

    userLati = userLocation.lati;
    userLongi = userLocation.longi;

    var tm_x;
    var tm_y;

    var obsJson;
    var obs;

    print(xCoordinate);
    print(yCoordinate);

    //카카오맵 역지오코딩
    var kakaoGeoUrl = Uri.parse('https://dapi.kakao.com/v2/local/geo/coord2address.json?x=$userLongi&y=$userLati&input_coord=WGS84');
    var kakaoGeo = await http.get(kakaoGeoUrl, headers: {"Authorization": "KakaoAK $kakaoApiKey"});
    //jason data
    String addr = kakaoGeo.body;


    //카카오맵 좌표계 변환
    var kakaoXYUrl = Uri.parse('https://dapi.kakao.com/v2/local/geo/transcoord.json?'
        'x=$userLongi&y=$userLati&input_coord=WGS84&output_coord=TM');
    var kakaoTM = await http.get(kakaoXYUrl, headers: {"Authorization": "KakaoAK $kakaoApiKey"});
    var TM = jsonDecode(kakaoTM.body);
    tm_x = TM['documents'][0]['x'];
    tm_y = TM['documents'][0]['y'];

    //근접 측정소
    var closeObs = 'http://apis.data.go.kr/B552584/MsrstnInfoInqireSvc/getNearbyMsrstnList?'
        'tmX=$tm_x&tmY=$tm_y&returnType=json&serviceKey=$apiKey';
    http.Response responseObs = await http.get(Uri.parse(closeObs));
    if(responseObs.statusCode == 200) {
      obsJson = jsonDecode(responseObs.body);
    }
    obs = obsJson['response']['body']['items'][0]['stationName'];
    print('측정소: $obs');

    if(now.hour < 2 || now.hour == 2 && now.minute < 10){
      baseDate_2am = getYesterdayDate();
      baseTime_2am = "2300";
    } else {
      baseDate_2am = getSystemTime();
      baseTime_2am = "0200";
    }
    // print(baseDate_2am);
    // print(baseTime_2am);
    //단기 예보 시간별 baseTime, baseDate
    //오늘 최저 기온
    String today2am = 'http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getVilageFcst?'
        'serviceKey=$apiKey&numOfRows=1000&pageNo=1&'
        'base_date=$baseDate_2am&base_time=$baseTime_2am&nx=$xCoordinate&ny=$yCoordinate&dataType=JSON';

    shortWeatherDate();
    //단기 예보 데이터
    String shortTermWeather = 'http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getVilageFcst?'
        'serviceKey=$apiKey&numOfRows=1000&pageNo=1&'
        'base_date=$baseDate&base_time=$baseTime&nx=$xCoordinate&ny=$yCoordinate&dataType=JSON';

    currentWeatherDate();
    //현재 날씨(초단기 실황)
    String currentWeather = 'http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getUltraSrtNcst?'
        'serviceKey=$apiKey&numOfRows=10&pageNo=1&'
        'base_date=$currentBaseDate&base_time=$currentBaseTime&nx=$xCoordinate&ny=$yCoordinate&dataType=JSON';

    superShortWeatherDate();
    //초단기 예보
    String superShortWeather = 'http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getUltraSrtFcst'
        '?serviceKey=$apiKey&numOfRows=60&pageNo=1'
        '&base_date=$sswBaseDate&base_time=$sswBaseTime&nx=$xCoordinate&ny=$yCoordinate&dataType=JSON';

    // print(baseDate);
    // print(baseTime);
    // print(currentBaseTime); //초단기 실황
    // print(currentBaseDate);
    // print(sswBaseTime); //초단기 예보
    // print(sswBaseDate);

    String airConditon = 'http://apis.data.go.kr/B552584/ArpltnInforInqireSvc/getMsrstnAcctoRltmMesureDnsty?'
        'stationName=$obs&dataTerm=DAILY&pageNo=1&ver=1.0'
        '&numOfRows=1&returnType=json&serviceKey=$apiKey';

    Network network = Network(today2am,
        shortTermWeather, currentWeather,
        superShortWeather, airConditon);

    // json 데이터
    var today2amData = await network.getToday2amData();
    var shortTermWeatherData = await network.getShortTermWeatherData();
    var currentWeatherData = await network.getCurrentWeatherData();
    var superShortWeatherData = await network.getSuperShortWeatherData();
    var airConditionData = await network.getAirConditionData();
    var addrData = jsonDecode(addr);

    // print('2am: $today2amData');
    // print('shortTermWeather: $shortTermWeatherData');
    // print('currentWeather: $currentWeatherData');
    // print('superShortWeather: $superShortWeatherData');
    // print('air: $airConditionData');

    Navigator.push(context, MaterialPageRoute(builder: (context){
      return WeatherScreen(
        parse2amData: today2amData,
        parseShortTermWeatherData: shortTermWeatherData,
        parseCurrentWeatherData: currentWeatherData,
        parseSuperShortWeatherData: superShortWeatherData,
        parseAirConditionData: airConditionData,
        parseAddrData: addrData
      );
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SpinKitWave(
              color: Colors.white,
              size: 60.0,
            ),
            SizedBox(
              height: 20,
            ),
            Text('위치 정보 업데이트 중',
              style: TextStyle(
                  fontFamily: 'tmon',
                  fontSize: 20.0,
                  color: Colors.black87
              ),
            )
          ],
        ),
      ),
    );
  }

  void shortWeatherDate(){
    if(now.hour < 2 || (now.hour == 2 && now.minute <= 10)){ //0시~2시 10분 사이 예보
      baseDate = getYesterdayDate();   //어제 날짜
      baseTime = "2300";
    } else if (now.hour < 5 || (now.hour == 5 && now.minute <= 10)){ //2시 11분 ~ 5시 10분 사이 예보
      baseDate = getSystemTime();
      baseTime = "0200";
    } else if (now.hour < 8 || (now.hour == 8 && now.minute <= 10)){ //5시 11분 ~ 8시 10분 사이 예보
      baseDate = getSystemTime();
      baseTime = "0500";
    } else if (now.hour < 11 || (now.hour == 11 && now.minute <= 10)){ //8시 11분 ~ 11시 10분 사이 예보
      baseDate = getSystemTime();
      baseTime = "0800";
    } else if (now.hour < 14 || (now.hour == 14 && now.minute <= 10)){ //11시 11분 ~ 14시 10분 사이 예보
      baseDate = getSystemTime();
      baseTime = "1100";
    } else if (now.hour < 17 || (now.hour == 17 && now.minute <= 10)){ //14시 11분 ~ 17시 10분 사이 예보
      baseDate = getSystemTime();
      baseTime = "1400";
    } else if (now.hour < 20 || (now.hour == 20 && now.minute <= 10)){ //17시 11분 ~ 20시 10분 사이 예보
      baseDate = getSystemTime();
      baseTime = "1700";
    } else if (now.hour < 23 || (now.hour == 23 && now.minute <= 10)){ //20시 11분 ~ 23시 10분 사이 예보
      baseDate = getSystemTime();
      baseTime = "2000";
    } else if (now.hour == 23 && now.minute >= 10){ //23시 11분 ~ 24시 사이 예보
      baseDate = getSystemTime();
      baseTime = "2300";
    }
  }

  //초단기 실황
  void currentWeatherDate() {
    //40분 이전이면 현재 시보다 1시간 전 `base_time`을 요청한다.
    if (now.minute <= 40){
      // 단. 00:40분 이전이라면 `base_date`는 전날이고 `base_time`은 2300이다.
      if (now.hour == 0) {
        currentBaseDate = DateFormat('yyyyMMdd').format(now.subtract(Duration(days:1)));
        currentBaseTime = '2300';
      } else {
        currentBaseDate = DateFormat('yyyyMMdd').format(now);
        currentBaseTime = DateFormat('HH00').format(now.subtract(Duration(hours:1)));
      }
    }
    //40분 이후면 현재 시와 같은 `base_time`을 요청한다.
    else{
      currentBaseDate = DateFormat('yyyyMMdd').format(now);
      currentBaseTime = DateFormat('HH00').format(now);
    }
  }

  //초단기 예보
  void superShortWeatherDate(){
    //45분 이전이면 현재 시보다 1시간 전 `base_time`을 요청한다.
    if (now.minute <= 45){
      // 단. 00:45분 이전이라면 `base_date`는 전날이고 `base_time`은 2330이다.
      if (now.hour == 0) {
        sswBaseDate = DateFormat('yyyyMMdd').format(now.subtract(Duration(days:1)));
        sswBaseTime = '2330';
      } else {
        sswBaseDate = DateFormat('yyyyMMdd').format(now);
        sswBaseTime = DateFormat('HH30').format(now.subtract(Duration(hours:1)));
      }
    }
    //45분 이후면 현재 시와 같은 `base_time`을 요청한다.
    else{ //if (now.minute > 45)
      sswBaseDate = DateFormat('yyyyMMdd').format(now);
      sswBaseTime = DateFormat('HH30').format(now);
    }
   }
}

