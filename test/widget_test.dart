import 'package:commute_train_tycoon/main.dart';
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

    await tester.tap(find.text('140 G'));
    await tester.pumpAndSettle();

    expect(find.text('작은 화분 Lv.1'), findsOneWidget);
    expect(find.text('작은 화분 배치 완료!'), findsOneWidget);

    await tester.tap(find.text('227 G'));
    await tester.pumpAndSettle();

    expect(find.text('작은 화분 Lv.2'), findsOneWidget);
    expect(find.text('작은 화분 Lv.2 업그레이드!'), findsOneWidget);
  });

  testWidgets('move tab grants the warp stub reward', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const CommuteTrainTycoonApp());
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('이동'));
    await tester.pump();
    await tester.tap(find.text('이동'));
    await tester.pump();

    expect(find.text('이동 보너스 스텁: +75 G'), findsOneWidget);
  });
}
