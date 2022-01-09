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
import 'package:hiiidan_weather/data/geo_network.dart';
import 'package:http/http.dart' as http;

final String apiKey = FlutterConfig.get('apiKey');
final String googleApiKey = FlutterConfig.get('google_map_api');
final String kakaoApiKey = FlutterConfig.get('kakao_api');


class Loading extends StatefulWidget {
  const Loading({Key? key}) : super(key: key);

  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  String? baseDate;
  String? baseTime;
  String? tmxBaseTime;
  String? currentBaseTime;
  String? shortBaseTime;

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

    print(xCoordinate);
    print(yCoordinate);

    var url = Uri.parse('https://dapi.kakao.com/v2/local/geo/coord2address.json?x=$userLongi&y=$userLati&input_coord=WGS84');
    var response = await http.get(url, headers: {"Authorization": "KakaoAK $kakaoApiKey"});

    print(response.body);

    var url2 = Uri.parse('https://dapi.kakao.com/v2/local/geo/coord2address.json?x=$userLongi&y=$userLati&input_coord=WGS84');
    var response2 = await http.get(url, headers: {"Authorization": "KakaoAK $kakaoApiKey"});

    // String geoAPI ='https://maps.googleapis.com/maps/api/geocode/json?latlng=$userLati,$userLongi&key=$googleApiKey&language=ko';
    //
    // GeoNetwork geoNetwork = GeoNetwork(geoAPI);
    // //jason data
    // var doroData = await geoNetwork.getDoro();
    // var si = doroData['results'][1]['address_components'][2]['short_name'];
    // var addr = doroData['results'][1]['address_components'][1]['short_name'];
    // print(si);
    // print(addr);

    // String observ = 'http://apis.data.go.kr/B552584/MsrstnInfoInqireSvc/getMsrstnList?addr=서울&stationName=종로구&'
    //     'pageNo=1&numOfRows=10&serviceKey=$apiKey&returnType=json';
    // GeoNetwork geoNetwork = GeoNetwork(geoAPI)


    await shortWeatherDate();  //단기 예보 시간별 baseTime, baseDate
    //오늘 최저 기온
    String todayTMN = 'http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getVilageFcst?'
        'serviceKey=$apiKey&numOfRows=50&pageNo=1&'
        'base_date=${getSystemTime()}&base_time=0200&nx=$xCoordinate&ny=$yCoordinate&dataType=JSON';

    //오늘 최고 기온
    String todayTMX = 'http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getVilageFcst?'
        'serviceKey=$apiKey&numOfRows=1000&pageNo=1&'
        'base_date=${getSystemTime()}&base_time=$tmxBaseTime&nx=$xCoordinate&ny=$yCoordinate&dataType=JSON';

    //단기 예보 데이터 api 링크
    String shortTermWeather = 'http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getVilageFcst?'
        'serviceKey=$apiKey&numOfRows=1000&pageNo=1&'
        'base_date=${getSystemTime()}&base_time=$baseTime&nx=$xCoordinate&ny=$yCoordinate&dataType=JSON';

    await currentWeatherDate(); //초단기 실황 baseTime
    print(currentBaseTime);
    //현재 날씨 API 링크
    String currentWeather = 'http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getUltraSrtNcst?'
        'serviceKey=$apiKey&numOfRows=10&pageNo=1&'
        'base_date=${getSystemTime()}&base_time=$currentBaseTime&nx=$xCoordinate&ny=$yCoordinate&dataType=JSON';

    await superShortWeatherDate(); //초단기 예보 baseTime
    print(shortBaseTime);
    String superShortWeather = 'http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getUltraSrtFcst'
        '?serviceKey=$apiKey&numOfRows=60&pageNo=1'
        '&base_date=${getSystemTime()}&base_time=$shortBaseTime&nx=$xCoordinate&ny=$yCoordinate&dataType=JSON';



    String airConditon = 'http://apis.data.go.kr/B552584/ArpltnInforInqireSvc/getMsrstnAcctoRltmMesureDnsty?'
        'stationName=운정&dataTerm=DAILY&pageNo=1&ver=1.0'
        '&numOfRows=1&returnType=json&serviceKey=$apiKey';

    Network network = Network(todayTMN, todayTMX,
        shortTermWeather, currentWeather,
        superShortWeather, airConditon);

    // json 데이터
    var todayTMNData = await network.getTodayTMNData();
    var todayTMXData = await network.getTodayTMXData();
    var shortTermWeatherData = await network.getShortTermWeatherData();
    var currentWeatherData = await network.getCurrentWeatherData();
    var superShortWeatherData = await network.getSuperShortWeatherData();
    var airConditionData = await network.getAirConditionData();

    print('1: $todayTMNData');
    print('2a: $todayTMXData');
    print('3: $shortTermWeatherData');
    print('4a: $currentWeatherData');
    print('5: $superShortWeatherData');
    print('6: $airConditionData');

    Navigator.push(context, MaterialPageRoute(builder: (context){
      return WeatherScreen(
        parseTodayTMNData: todayTMNData,
        parseTodayTMXData: todayTMXData,
        parseShortTermWeatherData: shortTermWeatherData,
        parseCurrentWeatherData: currentWeatherData,
        parseSuperShortWeatherData: superShortWeatherData,
        parseAirConditionData: airConditionData
          //,
        //parseDoroData: doroData
      );
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      body: Center(
        child: SpinKitWave(
          color: Colors.white,
          size: 60.0,
        ),
      ),
    );
  }

  Future shortWeatherDate() async{
    if(now.hour < 2 || (now.hour == 2 && now.minute <= 10)){ //0시~2시 10분 사이 예보
      baseDate = getYesterdayDate();   //어제 날짜
      baseTime = "2300";
      tmxBaseTime = "1100";
    } else if (now.hour < 5 || (now.hour == 5 && now.minute <= 10)){ //2시 11분 ~ 5시 10분 사이 예보
      baseDate = getSystemTime();
      baseTime = "0200";
      tmxBaseTime = "0200";
    } else if (now.hour < 8 || (now.hour == 8 && now.minute <= 10)){ //5시 11분 ~ 8시 10분 사이 예보
      baseDate = getSystemTime();
      baseTime = "0500";
      tmxBaseTime = "0500";
    } else if (now.hour < 11 || (now.hour == 11 && now.minute <= 10)){ //8시 11분 ~ 11시 10분 사이 예보
      baseDate = getSystemTime();
      baseTime = "0800";
      tmxBaseTime = "0800";
    } else if (now.hour < 14 || (now.hour == 14 && now.minute <= 10)){ //11시 11분 ~ 14시 10분 사이 예보
      baseDate = getSystemTime();
      baseTime = "1100";
      tmxBaseTime = "1100";
    } else if (now.hour < 17 || (now.hour == 17 && now.minute <= 10)){ //14시 11분 ~ 17시 10분 사이 예보
      baseDate = getSystemTime();
      baseTime = "1400";
      tmxBaseTime = "1100";
    } else if (now.hour < 20 || (now.hour == 20 && now.minute <= 10)){ //17시 11분 ~ 20시 10분 사이 예보
      baseDate = getSystemTime();
      baseTime = "1700";
      tmxBaseTime = "1100";
    } else if (now.hour < 23 || (now.hour == 23 && now.minute <= 10)){ //20시 11분 ~ 23시 10분 사이 예보
      baseDate = getSystemTime();
      baseTime = "2000";
      tmxBaseTime = "1100";
    }
  }

  Future currentWeatherDate() async{
    if ((now.hour == 1 && now.minute <= 41) || (now.hour == 2 && now.minute <= 40)){ //1시 41분 ~ 2시 40분 예보
      baseDate = getSystemTime();
      currentBaseTime = "0100";
    } else if ((now.hour == 2 && now.minute <= 41) || (now.hour == 3 && now.minute <= 40)){ //2시 41분 ~ 3시 40분 예보
      baseDate = getSystemTime();
      currentBaseTime = "0200";
    } else if ((now.hour == 3 && now.minute <= 41) || (now.hour == 4 && now.minute <= 40)){
      baseDate = getSystemTime();
      currentBaseTime = "0300";
    } else if ((now.hour == 4 && now.minute <= 41) || (now.hour == 5 && now.minute <= 40)){
      baseDate = getSystemTime();
      currentBaseTime = "0400";
    } else if ((now.hour == 5 && now.minute <= 41) || (now.hour == 6 && now.minute <= 40)){
      baseDate = getSystemTime();
      currentBaseTime = "0500";
    } else if ((now.hour == 6 && now.minute <= 41) || (now.hour == 7 && now.minute <= 40)){
      baseDate = getSystemTime();
      currentBaseTime = "0600";
    } else if ((now.hour == 7 && now.minute <= 41) || (now.hour == 8 && now.minute <= 40)){
      baseDate = getSystemTime();
      currentBaseTime = "0700";
    } else if ((now.hour == 8 && now.minute <= 41) || (now.hour == 9 && now.minute <= 40)){
      baseDate = getSystemTime();
      currentBaseTime = "0800";
    } else if ((now.hour == 9 && now.minute <= 41) || (now.hour == 10 && now.minute <= 40)){
      baseDate = getSystemTime();
      currentBaseTime = "0900";
    } else if ((now.hour == 10 && now.minute <= 41) || (now.hour == 11 && now.minute <= 40)){
      baseDate = getSystemTime();
      currentBaseTime = "1000";
    } else if ((now.hour == 11 && now.minute <= 41) || (now.hour == 12 && now.minute <= 40)){
      baseDate = getSystemTime();
      currentBaseTime = "1100";
    } else if ((now.hour == 12 && now.minute <= 41) || (now.hour == 13 && now.minute <= 40)){
      baseDate = getSystemTime();
      currentBaseTime = "1200";
    } else if ((now.hour == 13 && now.minute <= 41) || (now.hour == 14 && now.minute <= 40)){
      baseDate = getSystemTime();
      currentBaseTime = "1300";
    } else if ((now.hour == 14 && now.minute <= 41) || (now.hour == 15 && now.minute <= 40)){
      baseDate = getSystemTime();
      currentBaseTime = "1400";
    } else if ((now.hour == 15 && now.minute <= 41) || (now.hour == 16 && now.minute <= 40)){
      baseDate = getSystemTime();
      currentBaseTime = "1500";
    } else if ((now.hour == 16 && now.minute <= 41) || (now.hour == 17 && now.minute <= 40)){
      baseDate = getSystemTime();
      currentBaseTime = "1600";
    } else if ((now.hour == 17 && now.minute <= 41) || (now.hour == 18 && now.minute <= 40)){
      baseDate = getSystemTime();
      currentBaseTime = "1700";
    } else if ((now.hour == 18 && now.minute <= 41) || (now.hour == 19 && now.minute <= 40)){
      baseDate = getSystemTime();
      currentBaseTime = "1800";
    } else if ((now.hour == 19 && now.minute <= 41) || (now.hour == 20 && now.minute <= 40)){
      baseDate = getSystemTime();
      currentBaseTime = "1900";
    } else if ((now.hour == 20 && now.minute <= 41) || (now.hour == 21 && now.minute <= 40)){
      baseDate = getSystemTime();
      currentBaseTime = "2000";
    } else if ((now.hour == 21 && now.minute <= 41) || (now.hour == 22 && now.minute <= 40)){
      baseDate = getSystemTime();
      currentBaseTime = "2100";
    } else if ((now.hour == 22 && now.minute <= 41) || (now.hour == 23 && now.minute <= 40)){
      baseDate = getSystemTime();
      currentBaseTime = "2200";
    } else if ((now.hour == 23 && now.minute <= 41) || (now.hour == 0 && now.minute <= 40)){
      baseDate = getSystemTime();
      currentBaseTime = "2300";
    } else if ((now.hour == 0 && now.minute <= 41) || (now.hour == 1 && now.minute <= 40)) {
      baseDate = getSystemTime();
      currentBaseTime = "0000";
    }
  }

  Future superShortWeatherDate() async{
    if ((now.hour == 1 && now.minute <= 46) || (now.hour == 2 && now.minute <= 45)){ //1시 41분 ~ 2시 40분 예보
      baseDate = getSystemTime();
      shortBaseTime = "0130";
    } else if ((now.hour == 2 && now.minute <= 46) || (now.hour == 3 && now.minute <= 45)){ //2시 ~ 3시 40분 예보
      baseDate = getSystemTime();
      shortBaseTime = "0230";
    } else if ((now.hour == 3 && now.minute <= 46) || (now.hour == 4 && now.minute <= 45)){
      baseDate = getSystemTime();
      shortBaseTime = "0330";
    } else if ((now.hour == 4 && now.minute <= 46) || (now.hour == 5 && now.minute <= 45)){
      baseDate = getSystemTime();
      shortBaseTime = "0430";
    } else if ((now.hour == 5 && now.minute <= 46) || (now.hour == 6 && now.minute <= 45)){
      baseDate = getSystemTime();
      shortBaseTime = "0530";
    } else if ((now.hour == 6 && now.minute <= 46) || (now.hour == 7 && now.minute <= 45)){
      baseDate = getSystemTime();
      shortBaseTime = "0630";
    } else if ((now.hour == 7 && now.minute <= 46) || (now.hour == 8 && now.minute <= 45)){
      baseDate = getSystemTime();
      shortBaseTime = "0730";
    } else if ((now.hour == 8 && now.minute <= 46) || (now.hour == 9 && now.minute <= 45)){
      baseDate = getSystemTime();
      shortBaseTime = "0830";
    } else if ((now.hour == 9 && now.minute <= 46) || (now.hour == 10 && now.minute <= 45)){
      baseDate = getSystemTime();
      shortBaseTime = "0930";
    } else if ((now.hour == 10 && now.minute <= 46) || (now.hour == 11 && now.minute <= 45)){
      baseDate = getSystemTime();
      shortBaseTime = "1030";
    } else if ((now.hour == 11 && now.minute <= 46) || (now.hour == 12 && now.minute <= 45)){
      baseDate = getSystemTime();
      shortBaseTime = "1130";
    } else if ((now.hour == 12 && now.minute <= 46) || (now.hour == 13 && now.minute <= 45)){
      baseDate = getSystemTime();
      shortBaseTime = "1230";
    } else if ((now.hour == 13 && now.minute <= 46) || (now.hour == 14 && now.minute <= 45)){
      baseDate = getSystemTime();
      shortBaseTime = "1330";
    } else if ((now.hour == 14 && now.minute <= 46) || (now.hour == 15 && now.minute <= 45)){
      baseDate = getSystemTime();
      shortBaseTime = "1430";
    } else if ((now.hour == 15 && now.minute <= 46) || (now.hour == 16 && now.minute <= 45)){
      baseDate = getSystemTime();
      shortBaseTime = "1530";
    } else if ((now.hour == 16 && now.minute <= 46) || (now.hour == 17 && now.minute <= 45)){
      baseDate = getSystemTime();
      shortBaseTime = "1630";
    } else if ((now.hour == 17 && now.minute <= 46) || (now.hour == 18 && now.minute <= 45)){
      baseDate = getSystemTime();
      shortBaseTime = "1730";
    } else if ((now.hour == 18 && now.minute <= 46) || (now.hour == 19 && now.minute <= 45)){
      baseDate = getSystemTime();
      shortBaseTime = "1830";
    } else if ((now.hour == 19 && now.minute <= 46) || (now.hour == 20 && now.minute <= 45)){
      baseDate = getSystemTime();
      shortBaseTime = "1930";
    } else if ((now.hour == 20 && now.minute <= 46) || (now.hour == 21 && now.minute <= 45)){
      baseDate = getSystemTime();
      shortBaseTime = "2030";
    } else if ((now.hour == 21 && now.minute <= 46) || (now.hour == 22 && now.minute <= 45)){
      baseDate = getSystemTime();
      shortBaseTime = "2130";
    } else if ((now.hour == 22 && now.minute <= 46) || (now.hour == 23 && now.minute <= 45)){
      baseDate = getSystemTime();
      shortBaseTime = "2230";
    } else if ((now.hour == 23 && now.minute <= 46) || (now.hour == 0 && now.minute <= 45)){
      baseDate = getSystemTime();
      shortBaseTime = "2330";
    } else if ((now.hour == 0 && now.minute <= 46) || (now.hour == 1 && now.minute <= 45)) {
      baseDate = getSystemTime();
      shortBaseTime = "0030";
    }
  }
}

