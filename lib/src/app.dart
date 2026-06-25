import 'package:flutter/material.dart';

import 'features/game/screens/game_screen.dart';

class CommuteTrainTycoonApp extends StatelessWidget {
  const CommuteTrainTycoonApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF2E7D73);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '출근열차 키우기',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF6F0E6),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const GameScreen(),
    );
  }
}
