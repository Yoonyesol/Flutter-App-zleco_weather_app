🌞안드로이드 스튜디오를 이용한 플러터 날씨 어플 제작⛈
-------------------
## 날씨와 미세먼지 정보를 알려주는 정보 앱

![Animation22](https://user-images.githubusercontent.com/51500821/149667475-0f3f9e77-aa2d-481a-87d2-1138ae487da6.gif)



<br/><br/>
## 🏡주요 기능: 사용자 위치를 받아와서 해당 지역의 날씨/미세먼지 데이터 업데이트
* `geolocator`을 통해 현재 사용자의 위치 정보 불러오기
* 공공데이터 포털의 `기상청 단기예보 API`를 불러와 현재 지역 날씨 정보 받아오기
```
String shortTermWeather = 'http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getVilageFcst?'
        'serviceKey=$apiKey&numOfRows=1000&pageNo=1&'
        'base_date=$baseDate&base_time=$baseTime&nx=$xCoordinate&ny=$yCoordinate&dataType=JSON'; 
```
* 미세먼지 데이터는 `에어코리아 API`를 불러와 처리
```
String airConditon = 'http://apis.data.go.kr/B552584/ArpltnInforInqireSvc/getMsrstnAcctoRltmMesureDnsty?'
        'stationName=$obs&dataTerm=DAILY&pageNo=1&ver=1.0'
        '&numOfRows=1&returnType=json&serviceKey=$apiKey';
```

<img src = "https://user-images.githubusercontent.com/51500821/149667490-ec413805-968f-4b8b-85d0-5f5ca76efe4c.png" width="30%" height="30%">
<img src = "https://user-images.githubusercontent.com/51500821/149667492-a1174e0b-8667-4d3c-8baf-6be1d244b72d.png" width="30%" height="30%">



<br/><br/>
## ⚙추가 기능: 미세먼지 농도 기준과 오픈소스 라이선스 고지 내용 출력
* `setting` 페이지를 추가해 추가 정보를 보여주도록 했다.
* `Dialog`와 `ListView` 사용

<img src = "https://user-images.githubusercontent.com/51500821/149667494-9a0b5a4a-9715-4bf8-b5e3-b74ff1e2be47.png" width="30%" height="30%">
<img src = "https://user-images.githubusercontent.com/51500821/149667495-6ec8c0e0-8e75-45b7-a637-914bf6bf21ba.png" width="30%" height="30%">
<img src = "https://user-images.githubusercontent.com/51500821/149667497-13866632-700c-4a58-9f4a-601fa2620c6a.png" width="30%" height="30%">
<img src = "https://user-images.githubusercontent.com/51500821/149667498-42bc18c2-f222-4722-bd96-2320b0c948e1.png" width="30%" height="30%">



<br/><br/>
## ☺새로 학습한 내용
* 1. 스택 오버 플로우 사용 및 영어로 코딩관련 질문을 하는 것에 익숙해졌다.
* 2. REST API 사용법을 익혔다.
* 3. 저작권 준수를 위한 정보를 습득하였다.
* 4. 플러터 UI 구현에 익숙해졌다.
* 5. GitHub에 프로젝트를 올릴 때 중요한 정보(`ex. api key`)를 은닉하는 방법을 배웠다. (`.env`와 `.gitignore` 사용)
* 6. 플러터 dart 문법이나 다양한 날짜, 시간 표현, 깃 사용법 등에 대해 배웠다.😀



</br></br>
## 😭아직 추가하지 못한 기능 및 처리해야 할 에러
* 1. 기상청 http 에러 발생 시 어플 실행이 안 되는 에러
* 2. 특정 시각(0~2시)에 일부 데이터를 가져오지 못하는 에러
* 3. 너무 느린 로딩 속도
* 4. 클린코드, 리팩토링을 적용하지 못 했다.
* 5. 어플 상단 pin 아이콘 검색 기능 추가 및 pin 아이콘 삭제
