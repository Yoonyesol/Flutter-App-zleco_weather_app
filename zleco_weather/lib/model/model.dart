import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';

class Model{
  Widget? getSkyWeatherIcon(String code){
    if(code == '1'){  //맑음
      return SvgPicture.asset(
        'assets/weather_icon/clear-day.svg',
        width: 180.0,
        height: 180.0,
      );
    } else if(code == '3'){ //구름 많음
      return SvgPicture.asset(
        'assets/weather_icon/partly-cloudy-day.svg',
        width: 180.0,
        height: 180.0,
      );
    } else if(code == '4'){ //흐림
      return SvgPicture.asset(
        'assets/weather_icon/cloudy.svg',
        width: 180.0,
        height: 180.0,
      );
    }
  }

  Widget? getSkyWeatherDesc(String code){
    if(code == '1'){  //맑음
      return Text('맑음',
          style: TextStyle(
              fontFamily: 'tmon',
              fontSize: 20.0,
              color: Colors.white
          )
      );
    } else if(code == '3'){ //구름 많음
      return Text('구름 많음',
          style: TextStyle(
              fontFamily: 'tmon',
              fontSize: 20.0,
              color: Colors.white
          )
      );
    } else if(code == '4'){ //흐림
      return Text('흐림',
          style: TextStyle(
              fontFamily: 'tmon',
              fontSize: 20.0,
              color: Colors.white
          )
      );
    }
  }

  Widget? getAirIcon(String code) {
    int dens = int.parse(code);
    if (0 <= dens && dens <= 30) {
      return SvgPicture.asset(
        'assets/expression/good.svg',
        width: 50.0,
        height: 50.0,
      );
    } else if (31 <= dens && dens <= 80) {
      return SvgPicture.asset(
        'assets/expression/soso.svg',
        width: 50.0,
        height: 50.0,
      );
    }
    else if (81 <= dens && dens <= 150) {
      return SvgPicture.asset(
        'assets/expression/bad.svg',
        width: 50.0,
        height: 50.0,
      );
    }
    else if (151 <= dens) {
      return SvgPicture.asset(
        'assets/expression/so-bad.svg',
        width: 50.0,
        height: 50.0,
      );
    }
  }

    Widget? getAirDesc(String code) {
      int dens = int.parse(code);
      print(code);
      if (0 <= dens && dens <= 30) {
        return Text('좋음',
          style: TextStyle(
            fontFamily: 'tmon',
            fontSize: 18.0,
            color: Color(0xff1a0dab),
          ),
        );
      } else if (31 <= dens && dens <= 80) {
        return Text('보통',
          style: TextStyle(
            fontFamily: 'tmon',
            fontSize: 18.0,
            color: Color(0xff004b00),
          ),
        );
      }
      else if (81 <= dens && dens <= 150) {
        return Text('나쁨',
          style: TextStyle(
            fontFamily: 'tmon',
            fontSize: 18.0,
            color: Color(0xfff7781d),
          ),
        );
      }
      else if (151 <= dens) {
        return Text('매우 나쁨',
          style: TextStyle(
            fontFamily: 'tmon',
            fontSize: 18.0,
            color: Color(0xfff60000),
          ),
        );
      }

  }


Widget? getAirIcon25(String code) {
  int dens = int.parse(code);
  if (0 <= dens && dens <= 15) {
    return SvgPicture.asset(
      'assets/expression/good.svg',
      width: 50.0,
      height: 50.0,
    );
  } else if (16 <= dens && dens <= 35) {
    return SvgPicture.asset(
      'assets/expression/soso.svg',
      width: 50.0,
      height: 50.0,
    );
  }
  else if (36 <= dens && dens <= 75) {
    return SvgPicture.asset(
      'assets/expression/bad.svg',
      width: 50.0,
      height: 50.0,
    );
  }
  else if (76 <= dens) {
    return SvgPicture.asset(
      'assets/expression/so-bad.svg',
      width: 50.0,
      height: 50.0,
    );
  }
}
  Widget? getAirDesc25(String code) {
    int dens = int.parse(code);
    print(code);
    if (0 <= dens && dens <= 15) {
      return Text('좋음',
        style: TextStyle(
          fontFamily: 'tmon',
          fontSize: 18.0,
          color: Color(0xff1a0dab),
        ),
      );
    } else if (16 <= dens && dens <= 35) {
      return Text('보통',
        style: TextStyle(
          fontFamily: 'tmon',
          fontSize: 18.0,
          color: Color(0xff004b00),
        ),
      );
    }
    else if (36 <= dens && dens <= 75) {
      return Text('나쁨',
        style: TextStyle(
          fontFamily: 'tmon',
          fontSize: 18.0,
          color: Color(0xfff7781d),
        ),
      );
    }
    else if (76 <= dens) {
      return Text('매우 나쁨',
        style: TextStyle(
          fontFamily: 'tmon',
          fontSize: 18.0,
          color: Color(0xfff60000),
        ),
      );
    }
  }
}
