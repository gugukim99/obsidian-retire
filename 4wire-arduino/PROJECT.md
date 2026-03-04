# Project Rules

- 1. PET 기판위 그래핀을 레이저로 패터닝
- 2. Keithley 2460 SourceMeter 사용
- 3. 레이저로 패터닝하면서 그래핀의 표면 저항 측정
- 4. 저항 측정 방식은 van der Pauw
- 5. 패터닝 사각형 왼쪽위를 1번, 오른쪽 위를 2번, 오른쪽 아래를 3번, 왼쪽 아래를 4번으로 함
- 6. Sourcemeter와 아두이노 메가2560 을 연결해서 Force와 Sense를 van der Pauw 방식에 맞게 신호 인가하고 측정 함
- 7. 다음 순서로 진행
    * 측정 시작 신호 기다림
    * 측정 시작 신호 오면 측정 시작 함
    * 1-2에 Source, 3-4에 Measure
    * 3-4에 Source, 1-2에 Measure
    * 1-4에 Source, 2-3에 Measure
    * 2-3에 Source, 1-4에 Measure
    * Source는 100 uA, 1 초 후 전압 측정
- 8. 7 을 3번 반복 함