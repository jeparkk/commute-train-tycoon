import 'package:commute_train_tycoon/main.dart';
import 'package:commute_train_tycoon/src/features/game/models/device_location.dart';
import 'package:commute_train_tycoon/src/features/game/screens/game_screen.dart';
import 'package:commute_train_tycoon/src/features/game/services/location_service.dart';
import 'package:commute_train_tycoon/src/features/game/data/balance_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('shows the polished train cabin', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const CommuteTrainTycoonApp());
    await tester.pumpAndSettle();

    expect(find.text('출근열차 키우기'), findsOneWidget);
    expect(find.text('좌석 Lv.1'), findsOneWidget);
    expect(find.text('매점 Lv.1'), findsOneWidget);
    expect(find.text('장식 관리'), findsOneWidget);
    expect(find.text('COMMUTE EXPRESS'), findsOneWidget);
    expect(find.byIcon(Icons.train_rounded), findsOneWidget);
  });

  testWidgets('upgrades a slot when enough gold is available', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const CommuteTrainTycoonApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('좌석 Lv.1'));
    await tester.pump();

    expect(find.text('좌석 Lv.2'), findsOneWidget);
    expect(find.text('좌석 Lv.2 업그레이드!'), findsOneWidget);
  });

  testWidgets('buys and upgrades a decoration', (tester) async {
    SharedPreferences.setMockInitialValues({'gold': 700.0});

    await tester.pumpWidget(const CommuteTrainTycoonApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('장식 관리'));
    await tester.pumpAndSettle();

    expect(find.text('장식 상점'), findsOneWidget);
    expect(find.text('작은 화분'), findsOneWidget);

    final tinyPlant = BalanceConfig.decorations.first;

    await tester.tap(find.text('${tinyPlant.baseCost} G'));
    await tester.pumpAndSettle();

    expect(find.text('작은 화분 Lv.1'), findsOneWidget);
    expect(find.text('작은 화분 배치 완료!'), findsOneWidget);

    final nextCost = (tinyPlant.baseCost * BalanceConfig.decorationCostGrowth)
        .round();
    await tester.tap(find.text('$nextCost G'));
    await tester.pumpAndSettle();

    expect(find.text('작은 화분 Lv.2'), findsOneWidget);
    expect(find.text('작은 화분 Lv.2 업그레이드!'), findsOneWidget);
  });

  testWidgets('move tab opens movement bonus flow and settles a demo commute', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const CommuteTrainTycoonApp());
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('이동'));
    await tester.pump();
    await tester.tap(find.text('이동'));
    await tester.pumpAndSettle();

    expect(find.text('이동 보너스'), findsOneWidget);
    expect(find.text('실제 GPS'), findsOneWidget);
    expect(find.text('현재 위치 정산'), findsOneWidget);
    expect(find.text('아직 정산된 이동 기록이 없습니다.'), findsOneWidget);

    await tester.tap(find.text('테스트 이동 정산'));
    await tester.pumpAndSettle();

    expect(find.text('최근 이동 정산'), findsOneWidget);
    expect(find.text('7.2 km'), findsOneWidget);
    expect(find.text('이동 정산 완료: +259 G / +173 WP'), findsOneWidget);
  });

  testWidgets('GPS movement settlement stores a checkpoint before rewarding', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final locationService = _FakeLocationService([
      DeviceLocation(
        latitude: 37.5665,
        longitude: 126.9780,
        capturedAt: DateTime(2026, 6, 25, 8),
      ),
      DeviceLocation(
        latitude: 37.5755,
        longitude: 126.9780,
        capturedAt: DateTime(2026, 6, 25, 8, 20),
      ),
    ]);

    await tester.pumpWidget(
      MaterialApp(home: GameScreen(locationService: locationService)),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('이동'));
    await tester.pump();
    await tester.tap(find.text('이동'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('현재 위치 정산'));
    await tester.pumpAndSettle();

    expect(find.text('기준 위치 저장 완료. 다음 이동부터 보상이 정산됩니다'), findsOneWidget);

    await tester.tap(find.text('현재 위치 정산'));
    await tester.pumpAndSettle();

    expect(find.text('최근 이동 정산'), findsOneWidget);
    expect(find.text('1.0 km'), findsOneWidget);
    expect(find.text('GPS 이동 정산: +36 G / +24 WP'), findsOneWidget);
  });

  testWidgets('settles offline reward with a focused bottom sheet', (
    tester,
  ) async {
    final lastSavedAt = DateTime.now().subtract(const Duration(hours: 2));
    SharedPreferences.setMockInitialValues({
      'gold': 500.0,
      'lastSavedAt': lastSavedAt.millisecondsSinceEpoch,
    });

    await tester.pumpWidget(const CommuteTrainTycoonApp());
    await tester.pumpAndSettle();

    expect(find.text('차고지 수익 도착'), findsOneWidget);
    expect(find.text('정산 가능 골드'), findsOneWidget);
    expect(find.text('누적 시간'), findsOneWidget);
    expect(find.text('방치 효율'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, '수금'));
    await tester.pumpAndSettle();

    expect(find.text('차고지 수익 도착'), findsNothing);
    expect(find.text('오프라인 보상 수금 완료'), findsOneWidget);
  });
}

class _FakeLocationService implements LocationService {
  _FakeLocationService(this._locations);

  final List<DeviceLocation> _locations;
  int _index = 0;

  @override
  Future<DeviceLocation> getCurrentLocation() async {
    final location = _locations[_index];
    _index = (_index + 1).clamp(0, _locations.length - 1);
    return location;
  }

  @override
  double distanceBetweenMeters({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    return 1000;
  }
}
