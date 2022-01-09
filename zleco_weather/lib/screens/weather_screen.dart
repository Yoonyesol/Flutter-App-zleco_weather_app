import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:timer_builder/timer_builder.dart';
import 'package:hiiidan_weather/model/model.dart';

class WeatherScreen extends StatefulWidget {
  WeatherScreen({this.parseTodayTMNData, this.parseTodayTMXData,
    this.parseShortTermWeatherData, this.parseCurrentWeatherData,
    this.parseSuperShortWeatherData, this.parseAirConditionData
    //,
    //this.parseDoroData
  });
  final dynamic parseTodayTMNData;
  final dynamic parseTodayTMXData;
  final dynamic parseShortTermWeatherData;
  final dynamic parseCurrentWeatherData;
  final dynamic parseSuperShortWeatherData;
  final dynamic parseAirConditionData;
  //final dynamic parseDoroData;

  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  Model model = Model();
  var date = DateTime.now();

  var todayTMX;//일 최고기온
  var todayTMN;//일 최저기온
  var parsed_json;

  var currentT1H2;
  var currentT1H; //현재 기온
  String? currentREH; //현재 습도
  String? currentRN1; //1시간 강수량

  var skyCode;
  late Widget skyIcon;  //날씨 아이콘
  late Widget skyDesc;

  var air10;  //미세먼지
  var air25; //초미세먼지
  late Widget airIcon; //미세먼지 아이콘
  late Widget airDesc;
  late Widget airIcon25; //미세먼지 아이콘
  late Widget airDesc25;

  String? si;
  String? addr;

  String getSystemTime(){
    var now = DateTime.now();
    return DateFormat("h:mm a").format(now);
  }

  void initState(){
    super.initState();
    updateData(widget.parseTodayTMNData, widget.parseTodayTMXData,
        widget.parseShortTermWeatherData, widget.parseCurrentWeatherData,
        widget.parseSuperShortWeatherData, widget.parseAirConditionData
      //,
       //widget.parseDoroData
    );
  }

  void updateData(dynamic todayTMNData, dynamic todayTMXData,
      dynamic shortTermWeatherData, dynamic currentWeatherData,
      dynamic superShortWeatherData, dynamic airConditionData
      //,
      //dynamic doroData
      ){
    // print('tmndata: $todayTMN');
    // print('tmxdata: $todayTMX');
    // print('stwdata: $shortTermWeather');
    // print('cwddata: $currentWeather');

    //당일 최저 기온
    todayTMN = todayTMNData['response']['body']['items']['item'][48]['fcstValue'];

    //데이터의 총 갯수
    int totalCount = todayTMXData['response']['body']['totalCount'];
    for(int i = 0; i< totalCount; i++){//데이터 전체를 돌면서 원하는 데이터 추출
      parsed_json = todayTMXData['response']['body']['items']['item'][i];
      //당일 최고 기온
      if(parsed_json['category']=='TMX' && parsed_json['baseDate']==parsed_json['fcstDate']){
        todayTMX = parsed_json['fcstValue'];
        break;
      }
    }

    //현재 온도
    currentT1H = currentWeatherData['response']['body']['items']['item'][3]['obsrValue'];
    //습도
    currentREH = currentWeatherData['response']['body']['items']['item'][1]['obsrValue'];
    //1시간 강수량
    currentRN1 = currentWeatherData['response']['body']['items']['item'][2]['obsrValue'];

    //skyCode = superShortWeatherData['response']['body']['items']['item'][18]['fcstValue'];
    int totalCount2 = superShortWeatherData['response']['body']['totalCount'];
    for(int i = 0; i< totalCount2; i++){
      parsed_json = superShortWeatherData['response']['body']['items']['item'][i];
      //SKY 코드값
      if(parsed_json['category']=='SKY' && parsed_json['baseDate']==parsed_json['fcstDate']){
        skyCode = parsed_json['fcstValue'];
        break;
      }
    }

    //sky 날씨 아이콘
    skyIcon = model.getSkyWeatherIcon(skyCode)!;
    skyDesc = model.getSkyWeatherDesc(skyCode)!;

    air10 = airConditionData['response']['body']['items'][0]['pm10Value'];
    air25 = airConditionData['response']['body']['items'][0]['pm25Value'];

    airIcon = model.getAirIcon(air10)!;
    airDesc = model.getAirDesc(air10)!;
    airIcon25 = model.getAirIcon25(air25)!;
    airDesc25 = model.getAirDesc25(air25)!;

    // si = doroData['results'][1]['address_components'][2]['short_name'];
    // addr = doroData['results'][1]['address_components'][1]['short_name'];
    // print(si);
    // print(addr);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, //body 높이를 scaffold의 top까지 확장
      appBar: AppBar(
        backgroundColor: Colors.transparent,  //appBar 투명색
        elevation: 0.0, //그림자 농도
        leading: IconButton(
          icon: Icon(Icons.add_location_alt),
          iconSize: 30.0,
          onPressed: (){},
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.location_searching),
            onPressed: (){},
            iconSize: 30.0,
          )
        ],
      ),
      body: Container(
          child: Stack(
              children: [
                Image.asset(
                  'assets/cool-background.png',
                  fit: BoxFit.cover,  //지정된 영역을 꽉 채운다
                  width: double.infinity, //가로 너비 채우기
                  height:double.infinity,
                ),
                SingleChildScrollView(
                  child: Container(
                    margin: EdgeInsets.symmetric(
                        horizontal: 20
                    ),
                    child: Column(
                      children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      height: 50.0,
                                    ),
                                    skyIcon,
                                    skyDesc,
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text('습도(%) $currentREH',
                                      style: TextStyle(
                                          fontFamily: 'tmon',
                                          fontSize: 10.0,
                                          color: Colors.white
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text('1시간강수량(mm) $currentRN1',
                                      style: TextStyle(
                                          fontFamily: 'tmon',
                                          fontSize: 10.0,
                                          color: Colors.white
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                child: Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        height: 100.0,
                                      ),
                                      Container(
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              DateFormat('yyy년 M월 d일 ').format(date), //일월년
                                              style: TextStyle(
                                                  fontFamily: 'tmon',
                                                  fontSize: 10.0,
                                                  color: Colors.white
                                              ),
                                            ),
                                            Text(
                                                DateFormat('EEE.').format(date),
                                                style: TextStyle(
                                                    fontFamily: 'tmon',
                                                    fontSize: 10.0,
                                                    color: Colors.white
                                                )
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      TimerBuilder.periodic(
                                        (Duration(minutes: 1)), //1분 단위로 보여주기
                                        builder: (context){
                                          return Text(
                                              '${getSystemTime()}',
                                              style: TextStyle(
                                                  fontFamily: 'tmon',
                                                  fontSize: 10.0,
                                                  color: Colors.white
                                              )
                                          );
                                        },
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text('동패동, 파주',
                                        style: TextStyle(
                                            fontFamily: 'tmon',
                                            fontSize: 30.0,
                                            color: Colors.white
                                        ),
                                      ),
                                      // SizedBox(
                                      //   height: 10.0,
                                      // ),
                                      // Text('파주',
                                      //   style: TextStyle(
                                      //       fontFamily: 'tmon',
                                      //       fontSize: 18.0,
                                      //       color: Colors.white
                                      //   ),
                                      // ),
                                      SizedBox(
                                        height: 10.0,
                                      ),
                                      Text('$currentT1H°C',
                                        style: TextStyle(
                                            fontFamily: 'tmon',
                                            fontSize: 50.0,
                                            color: Colors.white
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10.0,
                                      ),
                                      Text('$todayTMN°C / $todayTMX°C',
                                        style: TextStyle(
                                            fontFamily: 'tmon',
                                            fontSize: 20.0,
                                            color: Colors.white
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              )
                            ]
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        //미세먼지/초미세먼지 inform box
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.all(17.0),
                              height: 150.0,
                              width: 370.0,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  image: DecorationImage(
                                      image: AssetImage('assets/microdust_inform_background.jpg'),
                                      fit: BoxFit.cover,
                                      opacity: 30
                                  )
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  //미세먼지 inform
                                  Container(
                                    child: Column(
                                      children: [
                                        Text('미세먼지',
                                          style: TextStyle(
                                              fontFamily: 'tmon',
                                              fontSize: 20.0,
                                              color: Colors.black87
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          children: [
                                            Column(
                                              children: [
                                                airIcon,
                                                SizedBox(
                                                  height: 8,
                                                ),
                                                airDesc,
                                              ],
                                            ),
                                            SizedBox(
                                              width: 10.0,
                                            ),
                                            Column(
                                              children: [
                                                Text('농도',
                                                  style: TextStyle(
                                                      fontFamily: 'tmon',
                                                      fontSize: 15.0,
                                                      color: Colors.black87
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Text('$air10 ㎍/㎥',
                                                  style: TextStyle(
                                                      fontFamily: 'tmon',
                                                      fontSize: 15.0,
                                                      color: Colors.black87
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                  VerticalDivider(
                                    thickness: 1,
                                    color: Colors.black54,
                                  ),
                                  //초미세먼지 inform
                                  Container(
                                    child: Column(
                                      children: [
                                        Text('초미세먼지',
                                          style: TextStyle(
                                              fontFamily: 'tmon',
                                              fontSize: 20.0,
                                              color: Colors.black87
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          children: [
                                            Column(
                                              children: [
                                                airIcon25,
                                                SizedBox(
                                                  height: 8,
                                                ),
                                                airDesc25,
                                              ],
                                            ),
                                            SizedBox(
                                              width: 10.0,
                                            ),
                                            Column(
                                              children: [
                                                Text('농도',
                                                  style: TextStyle(
                                                      fontFamily: 'tmon',
                                                      fontSize: 15.0,
                                                      color: Colors.black87
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Text('$air25 ㎍/㎥',
                                                  style: TextStyle(
                                                      fontFamily: 'tmon',
                                                      fontSize: 15.0,
                                                      color: Colors.black87
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20), //모서리를 둥글게
                                color: Colors.white,
                              ),
                              padding: EdgeInsets.all(17.0),
                              height: 370.0,
                              width: 370.0,
                              child: Column(
                                children:[
                                  Text('주간 날씨',
                                    style: TextStyle(
                                        fontFamily: 'tmon',
                                        fontSize: 20.0,
                                        color: Colors.black87
                                    )
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Text('요일',
                                            style: TextStyle(
                                                fontFamily: 'tmon',
                                                fontSize: 15.0,
                                                color: Colors.black87
                                            ),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text('습도',
                                            style: TextStyle(
                                                fontFamily: 'tmon',
                                                fontSize: 15.0,
                                                color: Colors.black87
                                            ),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Row(
                                            children: [
                                              SvgPicture.asset(
                                                'assets/weather_icon/fog.svg',
                                                width: 25.0,
                                                height: 25.0,
                                              ),
                                              Text('/',
                                                style: TextStyle(
                                                    fontFamily: 'tmon',
                                                    fontSize: 10.0,
                                                    color: Colors.black87
                                                ),
                                              ),
                                              SvgPicture.asset(
                                                'assets/weather_icon/clear-day.svg',
                                                width: 25.0,
                                                height: 25.0,
                                              ),

                                            ],
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text('최저/최고온도',
                                            style: TextStyle(
                                                fontFamily: 'tmon',
                                                fontSize: 15.0,
                                                color: Colors.black87
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 15,
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Text('요일',
                                            style: TextStyle(
                                                fontFamily: 'tmon',
                                                fontSize: 15.0,
                                                color: Colors.black87
                                            ),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text('습도',
                                            style: TextStyle(
                                                fontFamily: 'tmon',
                                                fontSize: 15.0,
                                                color: Colors.black87
                                            ),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Row(
                                            children: [
                                              SvgPicture.asset(
                                                'assets/weather_icon/fog.svg',
                                                width: 25.0,
                                                height: 25.0,
                                              ),
                                              Text('/',
                                                style: TextStyle(
                                                    fontFamily: 'tmon',
                                                    fontSize: 10.0,
                                                    color: Colors.black87
                                                ),
                                              ),
                                              SvgPicture.asset(
                                                'assets/weather_icon/clear-day.svg',
                                                width: 25.0,
                                                height: 25.0,
                                              ),

                                            ],
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text('최저/최고온도',
                                            style: TextStyle(
                                                fontFamily: 'tmon',
                                                fontSize: 15.0,
                                                color: Colors.black87
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 15,
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Text('요일',
                                            style: TextStyle(
                                                fontFamily: 'tmon',
                                                fontSize: 15.0,
                                                color: Colors.black87
                                            ),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text('습도',
                                            style: TextStyle(
                                                fontFamily: 'tmon',
                                                fontSize: 15.0,
                                                color: Colors.black87
                                            ),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Row(
                                            children: [
                                              SvgPicture.asset(
                                                'assets/weather_icon/fog.svg',
                                                width: 25.0,
                                                height: 25.0,
                                              ),
                                              Text('/',
                                                style: TextStyle(
                                                    fontFamily: 'tmon',
                                                    fontSize: 10.0,
                                                    color: Colors.black87
                                                ),
                                              ),
                                              SvgPicture.asset(
                                                'assets/weather_icon/clear-day.svg',
                                                width: 25.0,
                                                height: 25.0,
                                              ),

                                            ],
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text('최저/최고온도',
                                            style: TextStyle(
                                                fontFamily: 'tmon',
                                                fontSize: 15.0,
                                                color: Colors.black87
                                            ),
                                          ),
                                        ],
                                      ),SizedBox(
                                        height: 15,
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Text('요일',
                                            style: TextStyle(
                                                fontFamily: 'tmon',
                                                fontSize: 15.0,
                                                color: Colors.black87
                                            ),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text('습도',
                                            style: TextStyle(
                                                fontFamily: 'tmon',
                                                fontSize: 15.0,
                                                color: Colors.black87
                                            ),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Row(
                                            children: [
                                              SvgPicture.asset(
                                                'assets/weather_icon/fog.svg',
                                                width: 25.0,
                                                height: 25.0,
                                              ),
                                              Text('/',
                                                style: TextStyle(
                                                    fontFamily: 'tmon',
                                                    fontSize: 10.0,
                                                    color: Colors.black87
                                                ),
                                              ),
                                              SvgPicture.asset(
                                                'assets/weather_icon/clear-day.svg',
                                                width: 25.0,
                                                height: 25.0,
                                              ),

                                            ],
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text('최저/최고온도',
                                            style: TextStyle(
                                                fontFamily: 'tmon',
                                                fontSize: 15.0,
                                                color: Colors.black87
                                            ),
                                          ),
                                        ],
                                      ),SizedBox(
                                        height: 15,
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Text('요일',
                                            style: TextStyle(
                                                fontFamily: 'tmon',
                                                fontSize: 15.0,
                                                color: Colors.black87
                                            ),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text('습도',
                                            style: TextStyle(
                                                fontFamily: 'tmon',
                                                fontSize: 15.0,
                                                color: Colors.black87
                                            ),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Row(
                                            children: [
                                              SvgPicture.asset(
                                                'assets/weather_icon/fog.svg',
                                                width: 25.0,
                                                height: 25.0,
                                              ),
                                              Text('/',
                                                style: TextStyle(
                                                    fontFamily: 'tmon',
                                                    fontSize: 10.0,
                                                    color: Colors.black87
                                                ),
                                              ),
                                              SvgPicture.asset(
                                                'assets/weather_icon/clear-day.svg',
                                                width: 25.0,
                                                height: 25.0,
                                              ),

                                            ],
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text('최저/최고온도',
                                            style: TextStyle(
                                                fontFamily: 'tmon',
                                                fontSize: 15.0,
                                                color: Colors.black87
                                            ),
                                          ),
                                        ],
                                      ),SizedBox(
                                        height: 15,
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Text('요일',
                                            style: TextStyle(
                                                fontFamily: 'tmon',
                                                fontSize: 15.0,
                                                color: Colors.black87
                                            ),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text('습도',
                                            style: TextStyle(
                                                fontFamily: 'tmon',
                                                fontSize: 15.0,
                                                color: Colors.black87
                                            ),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Row(
                                            children: [
                                              SvgPicture.asset(
                                                'assets/weather_icon/fog.svg',
                                                width: 25.0,
                                                height: 25.0,
                                              ),
                                              Text('/',
                                                style: TextStyle(
                                                    fontFamily: 'tmon',
                                                    fontSize: 10.0,
                                                    color: Colors.black87
                                                ),
                                              ),
                                              SvgPicture.asset(
                                                'assets/weather_icon/clear-day.svg',
                                                width: 25.0,
                                                height: 25.0,
                                              ),

                                            ],
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text('최저/최고온도',
                                            style: TextStyle(
                                                fontFamily: 'tmon',
                                                fontSize: 15.0,
                                                color: Colors.black87
                                            ),
                                          ),
                                        ],
                                      ),SizedBox(
                                        height: 15,
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Text('요일',
                                            style: TextStyle(
                                                fontFamily: 'tmon',
                                                fontSize: 15.0,
                                                color: Colors.black87
                                            ),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text('습도',
                                            style: TextStyle(
                                                fontFamily: 'tmon',
                                                fontSize: 15.0,
                                                color: Colors.black87
                                            ),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Row(
                                            children: [
                                              SvgPicture.asset(
                                                'assets/weather_icon/fog.svg',
                                                width: 25.0,
                                                height: 25.0,
                                              ),
                                              Text('/',
                                                style: TextStyle(
                                                    fontFamily: 'tmon',
                                                    fontSize: 10.0,
                                                    color: Colors.black87
                                                ),
                                              ),
                                              SvgPicture.asset(
                                                'assets/weather_icon/clear-day.svg',
                                                width: 25.0,
                                                height: 25.0,
                                              ),

                                            ],
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text('최저/최고온도',
                                            style: TextStyle(
                                                fontFamily: 'tmon',
                                                fontSize: 15.0,
                                                color: Colors.black87
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Container(
                            child:
                            SizedBox(
                                height: 20,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      primary: Colors.transparent,
                                      elevation: 0.0
                                  ),
                                  child: Text('© 오픈소스 라이선스',
                                    style: TextStyle(
                                        fontSize: 12.0,
                                        color: Colors.black87
                                    ),
                                  ),
                                  onPressed: (){
                                    Future.delayed(Duration.zero, (){
                                      Navigator.of(context).push(
                                          MaterialPageRoute(builder: (_) => LicensePage()));
                                    });

                                  },
                                )
                            )
                        )
                      ],
                    ),
                  ),
                ),
              ]
          )
      ),
    );
  }
}
